# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!--- next entry here -->

## 0.5.1
2020-04-03

### Fixes

- prepare switch to zero.py inventory (39228466df8f424e1a0f386285ee9d1958dce648)
- re-introduced TF (3e82403ff5911fde6089426304c9418ddb7b0dff)

## 0.5.0
2020-04-02

### Features

- prototype network detection (e9a27d1402cc19d28e42f1ddfb128c87e08be9f8)
- implemented stacks (03ea5064bbc0e2dd9825788a3c2be21cf1c8188c)
- migrated Traefik to a separate Stack (0d477ef34b134fe6bdda81a74f53e3a1c654ed81)

### Fixes

- only enable certain Docker features when they are enabled globally (c3cfaae548fdc96db5580c88fb04f4e8fa8af2c0)
- tuned Traefik Stack (5c56934cfdf63482c9317e0b97f54d0925eb2746)

## 0.4.2
2020-04-02

### Fixes

- systemd for cgroups management in K8s (62630c5b9b7e54e28c5dd94d76aea2c7e76a29e8)

## 0.4.1
2020-04-01

### Fixes

- missing image for Container Scanning (0b26b3b3b8686fb9ed3a19d917e8fe8d6d806373)

## 0.4.0
2020-03-31

### Features

- added Kubernetes integration (c6beffd7a7920980a5b7c3863627574908fd6d71)

### Fixes

- Storidge installation (0b448faef8edd1467eeb57a1a2e0bc7010b484c8)

## 0.3.5
2020-03-26

### Fixes

- enabled Slack environment config (dbf4d3397cace275a1e8e35b665e708aea0494cf)

## 0.3.4
2020-03-25

### Fixes

- fixed runners (dbb7324572ff225ade9fa0783ce2ba9cc3796fde)

## 0.3.3
2020-03-23

### Fixes

- hostname error in backplane (ada4863867a46f61c39672ca6506facc218275df)

## 0.3.2
2020-03-23

### Fixes

- firewall interfaces (e37252b693db51c2b0fe77ba386d558e9a15f61b)

## 0.3.1
2020-03-23

### Fixes

- private ifaces (5901d4ab0ef8bb6f6560af18c877522c0b5fa7e1)

## 0.3.0
2020-03-23

### Features

- docker-entrypoint (51c6b9bcf19996c649afb5e4acdcc488983adb3a)

### Fixes

- missed files (fb941ca4a2bbe8228c4e516009964e875d64340a)

## 0.2.1
2020-03-22

### Fixes

- removed CI tags for runners (91a8d5a10340e4168067e424d098dc6474a84190)

## 0.2.0
2020-03-22

### Features

- enabled Debian (c67a01da5ce673b30ce386f668fc8dc9a0ee34f1)

### Fixes

- added dependencies for Windows deployments (24f1399317f03125a868680108eaa2d7e9e1ae39)

## 0.1.0
2020-03-20

### Features

- dynamodb credentials (48fb4b7a9135a82373ac140d5f4a75399ce533f9)
- change base image for docker build from alpine to python-slim (6ccc8431054ad9c166c0ce7a9ad10b38216fe2ec)
- improve caching (2a37a91844aeb10eaf12c13122113b72c818c047)
- reduced image layers (f2197190b5de2e2a994618e255689b0f97477426)
- reduced image size (6b9515f02dad369909a2ea3adba38561d1ee7a20)
- refactor code (a62fdafbb278a4532ee4b8b6e7facd29156490ab)
- pre-alpha release (48f6993b42053c1f1c65efbbee3831f65efca316)

### Fixes

- loki config (3fb297dec379ed42063c98b21693e7c9318b1b40)
- mc platform (c5290c432715d30e16a37e5dd88b31414d5a6d69)
- mc platform (7561ecd0d4460dcd22a1b2004734f54f2271bcc7)
- loki s3 lookup issues (379f4273f94fd6c9b57db851418aa438097523d9)
- loki dynamodb lookup issues (ef57648eae531f1e058b09877e02807a8e5f2a47)
- removed loki tags; issues with dynamodb (c2254e709acdde5572a376ebe6848213f842e47e)
- traefik debug; LE staging (1bd43f2d5fa5fc36073d567a9b31a2fd5a1a0d7b)
- proxy dns record (82f035bd21c56b5c1571f9fc66fbe44fd22566f2)
- replace ash with bash (8924e95a165374d22c225208024d17a319370738)
- insecure ci-method, cache-optimization (552275031985c5589be3862e04c2b85504ab1b9f)
- typo (1a452428829caa691fc64206aaa2e021e086c953)
- ci (ba33ebca05b8aa43efbb4b8a354db6747c202a0d)
- improve caching (68dad5f58f42ce9246de898618cddc1a88852f40)
- improve caching (4b39d3868a63fa83bb7ec59eacda2bd59fe48f41)
- improve caching (6101b9b04de8f06d3d01b2236e6c92858f5e392d)
- ci speed (670c1a33a72da5681dc1c9aa79cbda97c520dfa1)
- runners cache (0570e93c339c5353311dcc556bd787b2ed160f31)
- Cloudflare DNS Proxy (61912f85f4aef887a16606ab689ec47567f76968)
- remove README for now (7b1a82ca545ca6eeea126051cfbda161e240a6fe)
- removed legacy code (fd3face8b5253252363f89ae204897e7df522b81)
- removed legacy code (3acf537d6c9b582b277bd3c7bf9fea8f10cafaaa)
- removed legacy code (9c2bb392b0e666ae404dbe0f82a841fc21429f4e)
- removed legacy code (663560555bdefb6e9f0c1529689da820690bf3a5)
- millions of changes, too late to make a purposeful commit (24b8fa8a08c260e141a8acd27c82403b311db956)
- millions of changes, too late to make a purposeful commit (5ef900a69f500b49a95d5e13b8aadcc7c642084a)
- runner labels (627310a7fb1fe243581b6932267d7108fe0fdf27)
- added dependencies for Windows deployments (24f1399317f03125a868680108eaa2d7e9e1ae39)

## 0.1.1
2020-03-20

### Fixes

- runner labels (627310a7fb1fe243581b6932267d7108fe0fdf27)

## 0.1.0
2020-03-20

### Features

- dynamodb credentials (48fb4b7a9135a82373ac140d5f4a75399ce533f9)
- change base image for docker build from alpine to python-slim (6ccc8431054ad9c166c0ce7a9ad10b38216fe2ec)
- improve caching (2a37a91844aeb10eaf12c13122113b72c818c047)
- reduced image layers (f2197190b5de2e2a994618e255689b0f97477426)
- reduced image size (6b9515f02dad369909a2ea3adba38561d1ee7a20)
- refactor code (a62fdafbb278a4532ee4b8b6e7facd29156490ab)
- pre-alpha release (48f6993b42053c1f1c65efbbee3831f65efca316)

### Fixes

- loki config (3fb297dec379ed42063c98b21693e7c9318b1b40)
- mc platform (c5290c432715d30e16a37e5dd88b31414d5a6d69)
- mc platform (7561ecd0d4460dcd22a1b2004734f54f2271bcc7)
- loki s3 lookup issues (379f4273f94fd6c9b57db851418aa438097523d9)
- loki dynamodb lookup issues (ef57648eae531f1e058b09877e02807a8e5f2a47)
- removed loki tags; issues with dynamodb (c2254e709acdde5572a376ebe6848213f842e47e)
- traefik debug; LE staging (1bd43f2d5fa5fc36073d567a9b31a2fd5a1a0d7b)
- proxy dns record (82f035bd21c56b5c1571f9fc66fbe44fd22566f2)
- replace ash with bash (8924e95a165374d22c225208024d17a319370738)
- insecure ci-method, cache-optimization (552275031985c5589be3862e04c2b85504ab1b9f)
- typo (1a452428829caa691fc64206aaa2e021e086c953)
- ci (ba33ebca05b8aa43efbb4b8a354db6747c202a0d)
- improve caching (68dad5f58f42ce9246de898618cddc1a88852f40)
- improve caching (4b39d3868a63fa83bb7ec59eacda2bd59fe48f41)
- improve caching (6101b9b04de8f06d3d01b2236e6c92858f5e392d)
- ci speed (670c1a33a72da5681dc1c9aa79cbda97c520dfa1)
- runners cache (0570e93c339c5353311dcc556bd787b2ed160f31)
- Cloudflare DNS Proxy (61912f85f4aef887a16606ab689ec47567f76968)
- remove README for now (7b1a82ca545ca6eeea126051cfbda161e240a6fe)
- removed legacy code (fd3face8b5253252363f89ae204897e7df522b81)
- removed legacy code (3acf537d6c9b582b277bd3c7bf9fea8f10cafaaa)
- removed legacy code (9c2bb392b0e666ae404dbe0f82a841fc21429f4e)
- removed legacy code (663560555bdefb6e9f0c1529689da820690bf3a5)
- millions of changes, too late to make a purposeful commit (24b8fa8a08c260e141a8acd27c82403b311db956)
- millions of changes, too late to make a purposeful commit (5ef900a69f500b49a95d5e13b8aadcc7c642084a)

