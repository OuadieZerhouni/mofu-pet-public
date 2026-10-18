"""Replaces the 6.9" (APP_IPHONE_67) screenshot set of every locale on the editable
App Store version with ASO/screenshots/<locale>/*.png, in file-name order.

    ~/Documents/Apps/app-factory/.venv/bin/python tools/aso/upload_screenshots.py [--version 1.0.0]

Uses the app-factory ASC client and neko's chunked uploader (upload_asc_media.upload).
`asc.py listing push` sends text only; Apple refuses a submission without these
(STATE_ERROR.SCREENSHOT_REQUIRED.IPHONE_DYNAMIC_ISLAND).
"""
import argparse, importlib.util, pathlib, sys

H = pathlib.Path.home() / 'Documents/Apps'
sys.path.insert(0, str(H / 'app-factory/tools'))
spec = importlib.util.spec_from_file_location('neko_up', H / 'neko-cat-pet/tool/marketing/upload_asc_media.py')
up = importlib.util.module_from_spec(spec); spec.loader.exec_module(up)
import asc  # noqa: E402
from lib import asc_jwt  # noqa: E402

ROOT = pathlib.Path(__file__).resolve().parents[2] / 'ASO/screenshots'

ap = argparse.ArgumentParser(); ap.add_argument('--version', default='1.0.0'); args = ap.parse_args()
a = asc.app_for('com.ouadieZerhouni.mofuPet'); v = asc._editable_version(a['id'], args.version)
locs = {l['attributes']['locale']: l['id'] for l in asc_jwt.get_all(f"/v1/appStoreVersions/{v['id']}/appStoreVersionLocalizations")}
for loc, lid in sorted(locs.items()):
    files = sorted((ROOT / loc).glob('*.png'))
    if len(files) < 3:
        raise SystemExit(f'{loc}: only {len(files)} screenshots')
    for s in asc_jwt.get_all(f"/v1/appStoreVersionLocalizations/{lid}/appScreenshotSets"):
        if s['attributes']['screenshotDisplayType'] == 'APP_IPHONE_67':
            asc_jwt.request('DELETE', f"/v1/appScreenshotSets/{s['id']}")
    ss = asc_jwt.request('POST', '/v1/appScreenshotSets', body={'data': {'type': 'appScreenshotSets',
        'attributes': {'screenshotDisplayType': 'APP_IPHONE_67'},
        'relationships': {'appStoreVersionLocalization': {'data': {'type': 'appStoreVersionLocalizations', 'id': lid}}}}})['data']
    ids = [up.upload('appScreenshots', 'appScreenshotSet', ss['id'], f) for f in files]
    asc_jwt.request('PATCH', f"/v1/appScreenshotSets/{ss['id']}/relationships/appScreenshots",
                    body={'data': [{'type': 'appScreenshots', 'id': i} for i in ids]})
    print(loc, 'uploaded', len(ids))
