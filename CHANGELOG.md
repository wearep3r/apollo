# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!--- next entry here -->

## 0.7.1
2020-01-08

### Fixes

- configs (d2475834aa53ed8e6332a5903b3bed71b72f8007)

## 0.7.0
2020-01-06

### Features

- adding runner capabilities to managers for easier deployment (18ddef9d22c07af2e045c9151941d416555f0cc1)

### Fixes

- removed need for ssh in ci (c920c599853442115cc375a325ebc11b81efe9a5)
- ci with new runners (744a406a6759d824a7a5e2a4bf37ee4c94cc40b8)
- ci with new runners (ff3938358501cd45121412eca515aa3b6f537eee)

## 0.6.1
2020-01-05

### Fixes

- changed CIO dashboard (699344dca3857e0785b032f38b2c56319a4c2a52)

## 0.6.0
2020-01-05

### Breaking changes

#### BREAKING CHANGE (cab499c7551135227ba2631156ae8685c172a353)

feat: added CIO Grafana Dashboard

### Features

- added cio-exporter (d5e74496a62f53fcf9efb4f849c88c76b2e08210)

## 0.5.0
2020-01-05

### Features

- added Prometheus image (a5c8e88f7777a0574178c94edf659ca725f9e34e)
- added Prometheus image (bccb7ddfcf98cc2e80cf87d43937ed529f325444)
- added Grafana (a3b1e9e7499e16b756ec8f12319d792b174b6f65)
- added cio-exporter (d5e74496a62f53fcf9efb4f849c88c76b2e08210)

### Fixes

- prometheus chmod (8183b3f83c6d2f64e0b635a7de9f9a9862982e2a)
- make build stages manual (1213f8a7af053463f39a79a2a0d8c1f334f8d41b)
- **ci:** added grafana builds (86457eaca07d66a150ae7267e029856f72497d51)
- **ci:** added grafana builds (7d08d5473739d75d4ee347d36228e5fa3a646fc0)

## 0.5.0
2020-01-05

### Features

- added Prometheus image (a5c8e88f7777a0574178c94edf659ca725f9e34e)
- added Prometheus image (bccb7ddfcf98cc2e80cf87d43937ed529f325444)
- added Grafana (a3b1e9e7499e16b756ec8f12319d792b174b6f65)

### Fixes

- prometheus chmod (8183b3f83c6d2f64e0b635a7de9f9a9862982e2a)
- make build stages manual (1213f8a7af053463f39a79a2a0d8c1f334f8d41b)
- **ci:** added grafana builds (86457eaca07d66a150ae7267e029856f72497d51)
- **ci:** added grafana builds (7d08d5473739d75d4ee347d36228e5fa3a646fc0)

## 0.4.0
2020-01-05

### Breaking changes

#### BREAKING CHANGE: Cleanup (24bb49be68cf934c58da98eb8fdbe5ab74678225)

Cleanup
fix(ci): reordered

### Features

- added Prometheus image (a5c8e88f7777a0574178c94edf659ca725f9e34e)
- added Prometheus image (bccb7ddfcf98cc2e80cf87d43937ed529f325444)

### Fixes

- **ci:** order (9b426e544396c93f9254df3fd5430ae7e2ac979b)
- node-exporter dockerfile layout (93634cc45cfa6da13205e42e1077dafd148a93bf)
- node-exporter dockerfile layout (5f51c98b5dd7f5361e942c4bbfb3baa9845de5bc)
- node-exporter dockerfile layout (19031856e6843a58d680d6f91ef6c6673c798c25)
- dat stupid typo tho... (970fff114db55c4dd5af3d4b6b4d9e01e0a0df97)
- git (23ad04b1f4a9a38ba88bd10345d936213fe98613)
- git (f6d2b0e237b1ea90f3d004f0869109bd6ed9529a)
- renamed directories (a541983b863a0bbbbe7cd1af8dfd7f43c2a7a554)
- node-exporter command DRY (5cdc35e76a5c50bc3c0113440ef3fd0d223a5f4f)
- node-exporter (03b5551c831d5638678a5d091221dbdafc62e94a)
- prometheus chmod (8183b3f83c6d2f64e0b635a7de9f9a9862982e2a)

## 0.4.1
2020-01-05

### Fixes

- renamed directories (a541983b863a0bbbbe7cd1af8dfd7f43c2a7a554)
- node-exporter command DRY (5cdc35e76a5c50bc3c0113440ef3fd0d223a5f4f)
- node-exporter (03b5551c831d5638678a5d091221dbdafc62e94a)

## 0.4.0
2020-01-05

### Breaking changes

#### BREAKING CHANGE: Cleanup (24bb49be68cf934c58da98eb8fdbe5ab74678225)

Cleanup
fix(ci): reordered

### Fixes

- **ci:** order (9b426e544396c93f9254df3fd5430ae7e2ac979b)
- node-exporter dockerfile layout (93634cc45cfa6da13205e42e1077dafd148a93bf)
- node-exporter dockerfile layout (5f51c98b5dd7f5361e942c4bbfb3baa9845de5bc)
- node-exporter dockerfile layout (19031856e6843a58d680d6f91ef6c6673c798c25)
- dat stupid typo tho... (970fff114db55c4dd5af3d4b6b4d9e01e0a0df97)
- git (23ad04b1f4a9a38ba88bd10345d936213fe98613)
- git (f6d2b0e237b1ea90f3d004f0869109bd6ed9529a)

## 0.3.0
2020-01-05

### Breaking changes

#### BREAKING CHANGE: updated node-exporter versioning (258035afeaebd435b16f1d3cd5d3ea1e1967f9ce)

updated node-exporter versioning

#### Merge branch 'fix-release' into 'master' (ad7c089a352b08d3fb561700df08cdfed9dac84f)

updated node-exporter versioning

See merge request mbio/mbiosphere/infrastructure!26

### Fixes

- ci tuning (3683e8c61d4b39507d418c51a2c6e0e18c48fd7d)
- ci tuning (46cf4ce889c198d0d3a92ac5fe5dc1c320f30d1c)
- ci tuning (47ef0c9ec3f9d727478876770ee967af7404481f)
- ci tuning (6b319c578f86332d1df871ee1dcbc9e0c7db46fa)
- **ci:** included dind in release stage (14f827145214d771864b4232fec171943aeee830)
- **ci:** order (9b426e544396c93f9254df3fd5430ae7e2ac979b)

## 0.3.0
2020-01-05

### Breaking changes

#### BREAKING CHANGE: updated node-exporter versioning (258035afeaebd435b16f1d3cd5d3ea1e1967f9ce)

updated node-exporter versioning

#### Merge branch 'fix-release' into 'master' (ad7c089a352b08d3fb561700df08cdfed9dac84f)

updated node-exporter versioning

See merge request mbio/mbiosphere/infrastructure!26

### Fixes

- ci tuning (3683e8c61d4b39507d418c51a2c6e0e18c48fd7d)
- ci tuning (46cf4ce889c198d0d3a92ac5fe5dc1c320f30d1c)
- ci tuning (47ef0c9ec3f9d727478876770ee967af7404481f)
- ci tuning (6b319c578f86332d1df871ee1dcbc9e0c7db46fa)
- **ci:** included dind in release stage (14f827145214d771864b4232fec171943aeee830)

## 0.2.0
2020-01-05

### Breaking changes

#### BREAKING CHANGE: changed backplane networking and deployment method (d37c228e0e2043bb02549fd55a0ed1f8b6804891)

changed backplane networking and deployment method

#### BREAKING CHANGE: changed playbook order; added services provisioning via Ansible (8f0c00d5ed8c467ff14bbaeaffde54420258828b)

changed playbook order; added services provisioning via Ansible

### Features

- added Terraform (e0d2b084b23fa642109f01fd94f40aed70d18a5f)
- added Terraform (2b831cfd3aedd817fe8496502011238e31d2689a)

### Fixes

- **ci:** restructured stuff (2618f527e63a41e00b3afef5844d1c44d3554b0d)
- **ci:** changed user in Dockerfile (54a1a12c26060d8100a15c7aec6524a26d788085)
- **storidge:** extensive re-thinking of provisioning procedure; prepare infrastructure-image (78b51fa72e14e3916b931e82644c5abf23314c67)
- **storidge:** lots of refactorings... (f6b60ed3595bcc0217a14d3c2fbbbd81df53eb81)
- removed dind as basline requirement in gitlab-ci for speedup (a6a2a4d649b161e2678793ccdcb047c46db8308c)
- changed node-exporter build paths (42d56f8983ed3c72c472f2eb2be6b27201e9aae3)
- runner config tuning (4756bda54ba6e4caca4b473df858e94bd15ed095)
- runner config tuning (6020c727b30847f915997a87b62079fc9a50ef59)
- ci tuning (3683e8c61d4b39507d418c51a2c6e0e18c48fd7d)
- ci tuning (46cf4ce889c198d0d3a92ac5fe5dc1c320f30d1c)
- ci tuning (47ef0c9ec3f9d727478876770ee967af7404481f)
- ci tuning (6b319c578f86332d1df871ee1dcbc9e0c7db46fa)
- **ci:** included dind in release stage (14f827145214d771864b4232fec171943aeee830)

## 0.2.0
2020-01-05

### Breaking changes

#### BREAKING CHANGE: changed backplane networking and deployment method (d37c228e0e2043bb02549fd55a0ed1f8b6804891)

changed backplane networking and deployment method

#### BREAKING CHANGE: changed playbook order; added services provisioning via Ansible (8f0c00d5ed8c467ff14bbaeaffde54420258828b)

changed playbook order; added services provisioning via Ansible

### Features

- added Terraform (e0d2b084b23fa642109f01fd94f40aed70d18a5f)
- added Terraform (2b831cfd3aedd817fe8496502011238e31d2689a)

### Fixes

- **ci:** restructured stuff (2618f527e63a41e00b3afef5844d1c44d3554b0d)
- **ci:** changed user in Dockerfile (54a1a12c26060d8100a15c7aec6524a26d788085)
- **storidge:** extensive re-thinking of provisioning procedure; prepare infrastructure-image (78b51fa72e14e3916b931e82644c5abf23314c67)
- **storidge:** lots of refactorings... (f6b60ed3595bcc0217a14d3c2fbbbd81df53eb81)
- removed dind as basline requirement in gitlab-ci for speedup (a6a2a4d649b161e2678793ccdcb047c46db8308c)
- changed node-exporter build paths (42d56f8983ed3c72c472f2eb2be6b27201e9aae3)
- runner config tuning (4756bda54ba6e4caca4b473df858e94bd15ed095)
- runner config tuning (6020c727b30847f915997a87b62079fc9a50ef59)
- ci tuning (3683e8c61d4b39507d418c51a2c6e0e18c48fd7d)
- ci tuning (46cf4ce889c198d0d3a92ac5fe5dc1c320f30d1c)
- ci tuning (47ef0c9ec3f9d727478876770ee967af7404481f)
- ci tuning (6b319c578f86332d1df871ee1dcbc9e0c7db46fa)

## 0.2.0
2020-01-05

### Breaking changes

#### BREAKING CHANGE: changed backplane networking and deployment method (d37c228e0e2043bb02549fd55a0ed1f8b6804891)

changed backplane networking and deployment method

#### BREAKING CHANGE: changed playbook order; added services provisioning via Ansible (8f0c00d5ed8c467ff14bbaeaffde54420258828b)

changed playbook order; added services provisioning via Ansible

### Features

- added Terraform (e0d2b084b23fa642109f01fd94f40aed70d18a5f)
- added Terraform (2b831cfd3aedd817fe8496502011238e31d2689a)

### Fixes

- **ci:** Restructured Ansible directories (40635166d7fd3e9d228d815b0d0f7408ee9c7a63)
- **ci:** Changed update_config for Traefik (bd0312c1e763c275dc77bfc86227bb3e95c559bf)
- **ci:** Changed update_config for Traefik (25048be76c7f89b4e42a41d2abb20c6e869c2d2c)
- **ci:** Changed update_config for Traefik (2a699b45b66c15ec8f26ad419dec53c2f9a19ef5)
- **ci:** Fix Ansible Lint (126cc42bd9c50d6498b696ea12e3839b73ad012e)
- **ci:** Remove Traefik Healthcheck (0d36852fd8079e12fb3382225ae89e26dd551c5c)
- **ci:** Remove Traefik Healthcheck (10fd12562f66018c9291e2c402379b9df4ac1d55)
- **ci:** restructured stuff (2618f527e63a41e00b3afef5844d1c44d3554b0d)
- **ci:** changed user in Dockerfile (54a1a12c26060d8100a15c7aec6524a26d788085)
- **storidge:** extensive re-thinking of provisioning procedure; prepare infrastructure-image (78b51fa72e14e3916b931e82644c5abf23314c67)
- **storidge:** lots of refactorings... (f6b60ed3595bcc0217a14d3c2fbbbd81df53eb81)
- removed dind as basline requirement in gitlab-ci for speedup (a6a2a4d649b161e2678793ccdcb047c46db8308c)
- changed node-exporter build paths (42d56f8983ed3c72c472f2eb2be6b27201e9aae3)
- runner config tuning (4756bda54ba6e4caca4b473df858e94bd15ed095)
- runner config tuning (6020c727b30847f915997a87b62079fc9a50ef59)

## 0.1.4
2019-11-18

### Fixes

- **ci:** Remove Traefik Healthcheck (10fd12562f66018c9291e2c402379b9df4ac1d55)

## 0.1.3
2019-11-18

### Fixes

- **ci:** Remove Traefik Healthcheck (0d36852fd8079e12fb3382225ae89e26dd551c5c)

## 0.1.2
2019-11-18

### Fixes

- **ci:** Restructured Ansible directories (40635166d7fd3e9d228d815b0d0f7408ee9c7a63)
- **ci:** Changed update_config for Traefik (bd0312c1e763c275dc77bfc86227bb3e95c559bf)
- **ci:** Changed update_config for Traefik (25048be76c7f89b4e42a41d2abb20c6e869c2d2c)
- **ci:** Changed update_config for Traefik (2a699b45b66c15ec8f26ad419dec53c2f9a19ef5)
- **ci:** Fix Ansible Lint (126cc42bd9c50d6498b696ea12e3839b73ad012e)

## 0.1.1
2019-11-18

### Fixes

- **ci:** Ansible Linting and Testing (f5958a6ca24ac33414bc9e1ad9120335019515d5)
- **ci:** Ansible Linting and Testing (29ba89c26a7164b4ab07db178b05aee5efdbec81)
- **ansible:** Changed directory stucture (062748895052a81f9e35ad8d220a9ecfce4de620)
- **ci:** DIND TLS missing (1ff5bdb04ac4f6a9f14a6ef36e0f1be20cc09164)
- **ci:** Remove DOCKER_BUILDKIT (3d8f9f041b98bceff902ffa51c1a47a85c9bab20)
- **ci:** Fix Dockerfile (7b3621aeea4fd3c99416d6ebeba9736b0ae76693)
- **ci:** Fix Ansible world-writable issue (d1abf223907029174029a73ab3cf75cbe0cb5f3e)
- **ci:** Fix some Ansible Lint issues (7b69b5f1d0f6d218e812c2f5b691af9d137a0e4f)
- **ci:** Leverage Docker build cache (8c10dbe1a8b06e9c046686aace6a5f383b0b4625)
- **ci:** Fix some Ansible Lint issues (d4fa5e7b3ec8855e25b99bd4d3c96935a89cbe53)
- **ci:** Fix Image Release (35cef8b542da0640bd2babff88997f080e84bddf)
- **ci:** Fix Docker Cache (aa2ff807e50627721b5c6bf531919956278b4308)
- **ci:** Fix Docker Cache (7d8f9b0e780011cb39372a4b2ecfa1bd7a27b39b)
- **ci:** Fix Docker Cache (22efdefb36f92ca42128c3f708046d1494f428b2)
- **ci:** Fix Docker Cache (8ef3be41c3e9e2dfb91d56a4ad42f333ec8f5aec)
- **ci:** Release Image order (117c2b9d2be8d48ec6a4e502408f940b85392a97)
- **ci:** Fix Ansible Linting (1a500b080604897964262ef56afacde1a9fa33cd)

## 0.1.0
2019-11-17

### Breaking changes

#### Docker wrapper for repository (1e06d55ad0858f42973277f717f1dd0aa3e5467c)

Reorganized folder structure and dependencies

#### Docker wrapper for repository (506337f57b695c02344adf43dda69eb5f2064c3d)

Reorganized folder structure and dependencies

#### BREAKING CHANGE: Manual Deployment only (4834bd4a6bc099ef065ef92691556907a68938fb)

Manual Deployment only

#### BREAKING CHANGE: Manual Deployment only (3543d77d514bdc2937b07c822e44102c7c1f67ce)

Manual Deployment only

#### BREAKING CHANGE: Manual Deployments only (89c3f014eb1e2756021da5007ec848be2a7f9528)

Manual Deployments only

### Fixes

- **ci:** CHANGELOG for Release on every Branch (22d615bfc6768f4d64a6cbb25bb2020a3598e30f)
- **ci:** Reset Releases (afb3adaa3568ab76d58e9f64dd727f2ea37a09bd)
- **ci:** Reset Releases (b390e0667e24e7a931f74326db01253d100b6f38)
- **ci:** Dockerfile path (407726a45edbf3586ee67a81fcdb31c346e24471)

