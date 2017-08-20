#!/bin/bash

function norm () {
    echo $1 | tr '[:lower:]' '[:upper:]' | sed "s/^/000/" | grep -o '...$'
}

DEPS=$@


if [[ "$DEPS" == "" ]]
then
    echo "Please provide a list of departements, comma delimited"
    echo "Example for Paris : bash generate.travis.yml.sh 75,93,94,92"
    echo "Example for France : bash generate.travis.yml.sh 001,002,003,004,005,006,007,008,009,010,011,012,013,014,015,016,017,018,019,021,022,023,024,025,026,027,028,029,02A,02B,030,031,032,033,034,035,036,037,038,039,040,041,042,043,044,045,046,047,048,049,050,051,052,053,054,055,056,057,058,059,060,061,062,063,064,065,066,067,068,069,070,071,072,073,074,075,076,077,078,079,080,081,082,083,084,085,086,087,088,089,090,091,092,093,094,095,971,972,973,974,975,976,977,978,986"
    exit 1
fi

IFS=',' read -r -a DEP <<< "$@"

FIRST_DEP=$( norm ${DEP[0]} )
DEP=("${DEP[@]:1}")

### BEGIN
cat > .travis.yml << EOF
language: bash

sudo: required
dist: trusty

cache:
  directories:
    - workspace

branches:
  only:
    - /^\d+.*$/


install:
  - sudo apt-get update && sudo apt-get install -y p7zip-full


jobs:
  include:
EOF



###### DOWNLOAD DEP
cat >> .travis.yml << EOF
    - &download
      stage: departement download
      script: bash scripts/departement/download.sh \$DEP
      env: DEP=$FIRST_DEP
EOF
for i in "${!DEP[@]}"
do
    echo "    - <<: *download" >> .travis.yml
    echo "      env: DEP=$(norm ${DEP[$i]})" >> .travis.yml
done


###### PREPARE DEP
cat >> .travis.yml << EOF
    - &prepare
      stage: departement prepare
      script: 
        - chmod -R 777 workspace
        - bash scripts/departement/prepare.sh \$DEP
      env: DEP=$FIRST_DEP
EOF
for i in "${!DEP[@]}"
do
    echo "    - <<: *prepare" >> .travis.yml
    echo "      env: DEP=$(norm ${DEP[$i]})" >> .travis.yml
done


###### GENERATE DEP
cat >> .travis.yml << EOF
    - &generate
      stage: departement generate
      script: 
        - chmod -R 777 workspace
        - bash scripts/departement/generate.sh \$DEP
      env: DEP=$FIRST_DEP
      deploy:
        provider: releases
        api_key: \$GH_TOKEN
        file_glob: true
        file: workspace/**/*.tar.gz
        skip_cleanup: true
        on:
          repo: tcoupin/rok4_gen_bdortho
          tags: true
EOF
for i in "${!DEP[@]}"
do
    echo "    - <<: *generate" >> .travis.yml
    echo "      env: DEP=$(norm ${DEP[$i]})" >> .travis.yml
done



###### DOCKER DEP
cat >> .travis.yml << EOF
    - &docker
      stage: departement docker
      script: 
        - chmod -R 777 workspace
        - bash scripts/departement/docker-image.sh \$DEP
      env: DEP=$FIRST_DEP
EOF
for i in "${!DEP[@]}"
do
    echo "    - <<: *docker" >> .travis.yml
    echo "      env: DEP=$(norm ${DEP[$i]})" >> .travis.yml
done




###### DOWNLOAD WORLD
cat >> .travis.yml << EOF
    - stage: world download
      script: bash scripts/world/download.sh \$DEPS
      env: DEPS="$DEPS"
EOF

###### PREPARE WORLD
cat >> .travis.yml << EOF
    - stage: world prepare
      script: 
        - chmod -R 777 workspace
        - bash scripts/world/prepare.sh \$DEPS
      env: DEPS="$DEPS"
EOF

###### GENERATE WORLD
cat >> .travis.yml << EOF
    - stage: world generate
      script: 
        - chmod -R 777 workspace
        - bash scripts/world/generate.sh
      env: DEPS="$DEPS"
      deploy:
        provider: releases
        api_key: \$GH_TOKEN
        file_glob: true
        file: workspace/**/*.tar.gz
        skip_cleanup: true
        on:
          repo: tcoupin/rok4_gen_bdortho
          tags: true
EOF

###### DOCKER WORLD
cat >> .travis.yml << EOF
    - stage: world docker
      script: 
        - chmod -R 777 workspace
        - bash scripts/world/docker-image.sh 
      env: DEPS="$DEPS"

EOF
