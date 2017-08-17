## Generate data for rok4 server

Env var :

- DEP : departement

### Example

```
export DEP=75
bash doIt.sh
docker run -it -p 80:80 --rm -v $PWD/be4_work/pyramids:/rok4/config/pyramids rok4/rok4:latest
```

And open [http://127.0.0.1/rok4?service=WMS&request=GetMap&layers=BDORTHO-5M-075&styles&bbox=240000,6221000,290000,6270000&crs=EPSG:3857&format=image/jpeg&version=1.3.0&width=1024&height=1024] in browser.