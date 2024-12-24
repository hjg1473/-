![빅드림_S-TOP_썸네일](https://github.com/user-attachments/assets/f74683bf-1dd8-410e-a838-75fe8e067f0f)

# Block English v1.0

<p>$\bf{\large{\color{#6580DD}유아\ 영어\ 교육을\ 위한\ 비전\ 기반\ 솔루션\ 및\ 앱\ 개발}}$</p>

> 2024 성균관대 산학협력 프로젝트<br>
> 개발기간: 2024.04~2024.12


## 개발 인원 소개

|      함장건       |          (이름)         |       민경호         |          (이름)         |       우연서         |                                                                                                                  
| :------------------------------------------------------------------------------: | :---------------------------------------------------------------------------------------------------------------------------------------------------: | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: |  :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: |  :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: | 
|   <img width="160px" src="https://github.com/hjg1473.png" />    |                      <img width="160px" src="프사" />    |                   <img width="160px" src="https://github.com/aiden890.png"/>   |                       <img width="160px" src="프사" />    |                   <img width="160px" src="https://github.com/pilot-saving.png"/>   |
|   [@hjg1473](https://github.com/hjg1473)   |    [@이름](https://github.com/)  | [@이름](https://github.com/)  |    [@이름](https://github.com/)  | [@pilot-saving](https://github.com/pilot-saving)  | 
| 성균관대학교 소프트웨어학과 20학번 | 성균관대학교 소프트웨어학과  | 성균관대학교 소프트웨어학과 22학번  | 성균관대학교 소프트웨어학과  | 성균관대학교 소프트웨어학과 22학번 |

## 프로젝트 소개

해당 프로젝트는 빅드림 기업에서 요구한 어플리케이션을 개발하는 것입니다. 해당 어플리케이션은 문제를 제시하고, 학습자가 블록 잉글리시 교구를 통해 정답을 맞추면, 사진을 인식하여 피드백을 주는 프로세스로 구성되어 있습니다. 이를 기반으로한 간단한 게임 기능도 포함되어 있습니다. 또한, 관리자 역할이 존재하여 학습자들을 모니터링할 수 있는 서비스를 제공합니다. 

### 사용한 프레임워크

![FastAPI](https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=FastAPI&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=MySQL&logoColor=white)
![Redis](https://img.shields.io/badge/Redis-DC382D?style=for-the-badge&logo=Redis&logoColor=white)

![Elasticsearch](https://img.shields.io/badge/Elasticsearch-005571?style=for-the-badge&logo=elasticsearch&logoColor=white)
![Logstash](https://img.shields.io/badge/Logstash-000000?style=for-the-badge&logo=logstash&logoColor=white)
![Kibana](https://img.shields.io/badge/Kibana-E8478B?style=for-the-badge&logo=kibana&logoColor=white)

![PaddleOCR](https://img.shields.io/badge/PaddleOCR-0076CE?style=for-the-badge&logo=pytorch&logoColor=white)

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=Flutter&logoColor=white)


## 시작 가이드

### Prerequisites

- Ubuntu 22.04 
- docker
- docker-compose
- Flutter
- Android Studio
- XCode

### Installing
``` bash
$ git clone https://github.com/
```

#### Backend
```
$ cd app
$ docker-compose up --build
```

#### Frontend
```
$ cd block_english
```

## 주요 기능

### :white_check_mark: 회원 관련 기능
- 로그인 / 회원가입 / 회원 정보 수정
- JWT 사용

### :white_check_mark: 문제 관련 기능
- paddleOCR 을 사용해 블럭 인식
- 틀린 문제 유형 판단 알고리즘 구현

### :white_check_mark: 모니터링 관련 기능
- DB 데이터를 전처리 후 제공
- ELK 스택을 이용해 사용자 로그 기록

### :white_check_mark: 게임 기능 
- WebSocket을 통해 실시간 서비스 구현
- 랜덤 선택된 문제를 통해 진행

---
## 아키텍처

### 디렉터리 구조
```bash
app
├── alembic/
├── src
│   ├── auth : 로그인 / 회원가입 관련 api
│   │   ├── router.py
│   │   ├── schemas.py  # pydantic models
│   │   ├── models.py  # db models
│   │   ├── dependencies.py
│   │   ├── config.py  # local configs
│   │   ├── constants.py
│   │   ├── exceptions.py
│   │   ├── service.py
│   │   └── utils.py
│   ├── aws
│   │   ├── client.py  # client model for external service communication
│   │   ├── schemas.py
│   │   ├── config.py
│   │   ├── constants.py
│   │   ├── exceptions.py
│   │   └── utils.py
│   ├── game : 게임 관련 api
│   │   ├── router.py
│   │   ├── schemas.py  # pydantic models
│   │   ├── models.py  # db models
│   │   ├── dependencies.py
│   │   ├── config.py  # local configs
│   │   ├── constants.py
│   │   ├── exceptions.py
│   │   ├── service.py
│   │   └── utils.py
│   ├── problem : 문제 관련 api
│   │   ├── router.py
│   │   ├── schemas.py  # pydantic models
│   │   ├── models.py  # db models
│   │   ├── dependencies.py
│   │   ├── config.py  # local configs
│   │   ├── constants.py
│   │   ├── exceptions.py
│   │   ├── service.py
│   │   └── utils.py
│   ├── student : 학생 관련 api
│   │   ├── router.py
│   │   ├── schemas.py  # pydantic models
│   │   ├── models.py  # db models
│   │   ├── dependencies.py
│   │   ├── config.py  # local configs
│   │   ├── constants.py
│   │   ├── exceptions.py
│   │   ├── service.py
│   │   └── utils.py
│   ├── super : 관리자 관련 api
│   │   ├── router.py
│   │   ├── schemas.py  # pydantic models
│   │   ├── models.py  # db models
│   │   ├── dependencies.py
│   │   ├── config.py  # local configs
│   │   ├── constants.py
│   │   ├── exceptions.py
│   │   ├── service.py
│   │   └── utils.py
│   ├── user : 회원 관련 api
│   │   ├── router.py
│   │   ├── schemas.py  # pydantic models
│   │   ├── models.py  # db models
│   │   ├── dependencies.py
│   │   ├── config.py  # local configs
│   │   ├── constants.py
│   │   ├── exceptions.py
│   │   ├── service.py
│   │   └── utils.py
│   ├── posts
│   │   ├── router.py
│   │   ├── schemas.py
│   │   ├── models.py
│   │   ├── dependencies.py
│   │   ├── constants.py
│   │   ├── exceptions.py
│   │   ├── service.py
│   │   └── utils.py
│   ├── paddleocr/
│   ├── logs/
│   ├── config.py  # global configs
│   ├── models.py  # global models
│   ├── logging_setup.py
│   ├── cache.py  
│   ├── exceptions.py  # global exceptions
│   ├── pagination.py  # global module e.g. pagination
│   ├── database.py  # db connection related stuff
│   └── main.py
├── templates/
│   └── index.html
├── requirements
│   ├── base.txt
│   ├── dev.txt
│   └── prod.txt
├── elasticsearch/config
│   └── elasticsearch.yml
├── kibana/config
│   └── kibana.yml
├── logstash/pipeline
│   └── logstash.conf
├── nginx
│   └── nginx.conf
├── ocr_models
│   └── model file 2.zip
├── requirements.txt
├── docker-compose.yml
├── dockerfile
├── .env
├── .gitignore
├── logging.ini
└── alembic.ini
```
