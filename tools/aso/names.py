"""Name census: every App Store app whose name/seller/bundle contains "mofu"/"もふ".

    python tools/aso/names.py        # ~2 min (iTunes Search API, throttled)

Run on submission day: Apple rejects a duplicate app name at record creation,
and new Mofu-named apps keep appearing. Output: build/mofu_names.json + a table.
"""
import json,os,urllib.request,urllib.parse,time,sys
os.makedirs("build",exist_ok=True)
terms=["mofu","mofumofu","mofu pet","mofu fluffy pet","mofu mofu","もふもふ"]
cs=["us","gb","jp","de","br","sa","fr","kr","tw","mx","es"]
seen={}
for c in cs:
    for t in terms:
        u="https://itunes.apple.com/search?"+urllib.parse.urlencode({"term":t,"country":c,"entity":"software","limit":200})
        try:
            d=json.load(urllib.request.urlopen(u,timeout=30))
        except Exception as e:
            print("ERR",c,t,e,file=sys.stderr); time.sleep(5); continue
        for r in d["results"]:
            n=r["trackName"]
            if "mofu" in n.lower() or "もふ" in n or "mofu" in r.get("sellerName","").lower() or "mofu" in r.get("bundleId","").lower():
                seen.setdefault(r["trackId"],{"name":n,"bundle":r["bundleId"],"seller":r["sellerName"],"cs":set(),"rc":{}, "upd":r["currentVersionReleaseDate"][:10],"rel":r["releaseDate"][:10],"genre":r["primaryGenreName"]})
                seen[r["trackId"]]["cs"].add(c)
                seen[r["trackId"]]["rc"][c]=r.get("userRatingCount")
        time.sleep(2)
json.dump({k:{**v,"cs":sorted(v["cs"])} for k,v in seen.items()},open("build/mofu_names.json","w",encoding="utf-8"),ensure_ascii=False,indent=1)
for k,v in sorted(seen.items(),key=lambda x:x[1]["name"].lower()):
    print(k,"|",v["name"],"|",v["bundle"],"|",v["seller"],"|",v["genre"],"|",v["rel"],v["upd"],"|",",".join(sorted(v["cs"])),"|",v["rc"])
