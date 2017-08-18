## Generate data for rok4 server

### Generate department

```
DEP=75
bash scripts/department/download.sh $DEP
bash scripts/department/prepare.sh $DEP
bash scripts/department/generate.sh $DEP
```

An archive is present at workspace/075/D075-alone.tar.gz

You could test WMTS and WMS by running rok4 : 
```
docker run -it -p 80:80 --rm -v $PWD/workspace/075/be4_work/BDORTHO-5M-075:/rok4/config/pyramids/BDORTHO-5M-075 rok4/rok4
```

And open http://127.0.0.1/rok4?service=WMS&request=GetMap&layers=BDORTHO-5M-075&styles&bbox=240000,6221000,290000,6270000&crs=EPSG:3857&format=image/jpeg&version=1.3.0&width=1024&height=1024 in browser or try it in QGIS.