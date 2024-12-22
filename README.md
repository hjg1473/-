![빅드림_S-TOP_썸네일](https://github.com/user-attachments/assets/f74683bf-1dd8-410e-a838-75fe8e067f0f)

# Block English v1.0

<p>$\bf{\large{\color{#6580DD}유아\ 영어\ 교육을\ 위한\ 비전\ 기반\ 솔루션\ 및\ 앱\ 개발}}$</p>

> 2024 성균관대 산학협력 프로젝트<br>
> 개발기간: 2024.04~2024.12


## 개발 인원 소개

|      함장건       |          (이름)         |       (이름)         |          (이름)         |       (이름)         |                                                                                                                  
| :------------------------------------------------------------------------------: | :---------------------------------------------------------------------------------------------------------------------------------------------------: | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: |  :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: |  :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: | 
|   <img width="160px" src="https://github.com/hjg1473.png" />    |                      <img width="160px" src="프사" />    |                   <img width="160px" src="프사"/>   |                       <img width="160px" src="프사" />    |                   <img width="160px" src="프사"/>   |
|   [@hjg1473](https://github.com/hjg1473)   |    [@이름](https://github.com/)  | [@이름](https://github.com/)  |    [@이름](https://github.com/)  | [@이름](https://github.com/)  | 
| 성균관대학교 소프트웨어학과 20학번 | 성균관대학교 소프트웨어학과  | 성균관대학교 소프트웨어학과  | 성균관대학교 소프트웨어학과  | 성균관대학교 소프트웨어학과  |

## 프로젝트 소개

해당 프로젝트는 빅드림 기업의 블록 잉글리시 교육 프로세스를 어플리케이션화 하고, 더욱 확장성 높은 서비스를 제공하는 것이 목표입니다. 

### 사용한 프레임워크

![FastAPI](https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=FastAPI&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=MySQL&logoColor=white)
![Redis](https://img.shields.io/badge/Redis-DC382D?style=for-the-badge&logo=Redis&logoColor=white)

![Elasticsearch](https://img.shields.io/badge/Elasticsearch-005571?style=for-the-badge&logo=elasticsearch&logoColor=white)
![Logstash](https://img.shields.io/badge/Logstash-000000?style=for-the-badge&logo=logstash&logoColor=white)
![Kibana](https://img.shields.io/badge/Kibana-E8478B?style=for-the-badge&logo=kibana&logoColor=white)

![PaddleOCR](https://img.shields.io/badge/PaddleOCR-0076CE?style=for-the-badge&logo=pytorch&logoColor=white)

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=Flutter&logoColor=white)


## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

What things you need to install the software and how to install them

```
Give examples
```

### Installing
``` bash
$ git clone https://github.com/
```

#### Backend
```
$ cd app
$ cd src
$ uvicorn main:app --reload
```

#### Frontend
```

```

End with an example of getting some data out of the system or using it for a little demo

## Running the tests

Explain how to run the automated tests for this system

### Break down into end to end tests

Explain what these tests test and why

```
Give an example
```

### And coding style tests

Explain what these tests test and why

```
Give an example
```

## Deployment

Add additional notes about how to deploy this on a live system

## Built With

* [Dropwizard](http://www.dropwizard.io/1.0.2/docs/) - The web framework used
* [Maven](https://maven.apache.org/) - Dependency Management
* [ROME](https://rometools.github.io/rome/) - Used to generate RSS Feeds
* 

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Hat tip to anyone whose code was used
* Inspiration
* etc

---
## 아키텍처

### 디렉터리 구조
```bash
app
├── alembic/
├── src
│   ├── auth
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
│   ├── game
│   │   ├── router.py
│   │   ├── schemas.py  # pydantic models
│   │   ├── models.py  # db models
│   │   ├── dependencies.py
│   │   ├── config.py  # local configs
│   │   ├── constants.py
│   │   ├── exceptions.py
│   │   ├── service.py
│   │   └── utils.py
│   ├── problem
│   │   ├── router.py
│   │   ├── schemas.py  # pydantic models
│   │   ├── models.py  # db models
│   │   ├── dependencies.py
│   │   ├── config.py  # local configs
│   │   ├── constants.py
│   │   ├── exceptions.py
│   │   ├── service.py
│   │   └── utils.py
│   ├── student
│   │   ├── router.py
│   │   ├── schemas.py  # pydantic models
│   │   ├── models.py  # db models
│   │   ├── dependencies.py
│   │   ├── config.py  # local configs
│   │   ├── constants.py
│   │   ├── exceptions.py
│   │   ├── service.py
│   │   └── utils.py
│   ├── super
│   │   ├── router.py
│   │   ├── schemas.py  # pydantic models
│   │   ├── models.py  # db models
│   │   ├── dependencies.py
│   │   ├── config.py  # local configs
│   │   ├── constants.py
│   │   ├── exceptions.py
│   │   ├── service.py
│   │   └── utils.py
│   ├── user
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
