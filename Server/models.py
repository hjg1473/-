import enum
from sqlalchemy import Boolean, Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from database import Base
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship, sessionmaker

class Users(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)# PK, 사용자가 입력 안해도 값 생성(1,2,3...)
    username = Column(String, unique=True, index=True)# 아이디
    hashed_password = Column(String)# 해시된 비밀번호
    email = Column(String, unique=True, index=True)# 이메일 (교사만 해당)
    name = Column(String)# 실명
    age = Column(Integer)# 나이
    role = Column(String, index=True)# 역할 구분 (teacher or student)
    group = Column(Integer)# 분반(학생만)
    idToken = Column(String)# 고유 토큰(선생님만) 서버에서 설정
#     # 관계 설정
#     students = relationship("Users", back_populates="teacher", foreign_keys="User.teacher_id")
#     teacher_id = Column(Integer, ForeignKey("users.id"), nullable=True)# 교사 ID (학생만 해당) , 교사는 Null
#     teacher = relationship("Users", back_populates="students", remote_side=[id])
    
#     studyInfo = relationship("StudyInfo", back_populates="owner")# 학생일 경우 studyInfo와 관계 설정


# class StudyInfo(Base):# 학습 정보 
#     __tablename__ = "studyInfo"
#     __table_args__ = {'extend_existing': True}

#     id = Column(Integer, primary_key=True, index=True)# PK
#     stdLevel = Column(Integer)# 학생 수준
#     student_id = Column(Integer, ForeignKey("studyInfo.id"))# FK, 학습 정보 테이블 :: 한 명의 학생은 하나의 학습 정보 테이블을 가진다.

#     problem_owner = relationship("Problems", back_populates="problem")
#     owner = relationship("Students", back_populates="studyInfo")

# class Problems(Base):# 문제
#     __tablename__ = "problems"
#     __table_args__ = {'extend_existing': True}

#     id = Column(Integer, primary_key=True, index=True) # PK
#     season = Column(String)# 시즌(1,2,custom,...,AI)
#     type = Column(String)# 유형(문버, 단어 등등)
#     problemLevel = Column(Integer)# 문제 난이도(1~3)
#     koreaProblem = Column(String)# 한글 문장
#     englishProblem = Column(String)# 영어 문장
#     img_path = Column(String)#문제 이미지(optional)
#     TStudyInfo_id = Column(Integer, ForeignKey("studyInfo.id"))# 맞은 문제 FK :: 하나의 학습 정보는 여러 개의 맞은 문제를 가진다. 
#     FStudyInfo_id = Column(Integer, ForeignKey("studyInfo.id"))# 틀린 문제 FK :: 하나의 학습 정보는 여러 개의 틀린 문제를 가진다.
#     cproblem_id = Column(Integer, ForeignKey("customProblemSet.id")) # 문제 테이블 id.FK :: 하나의 커스텀 문제 세트는 여러 개의 문제를 가진다.

#     problem = relationship("StudyInfo", back_populates="problem_owner")
#     cproblem = relationship("CustomProblemSet", back_populates="cp_owner")

# class CustomProblemSet(Base):# 커스텀 문제 세트
#     __tablename__ = "customProblemSet"
#     __table_args__ = {'extend_existing': True}

#     id = Column(Integer, primary_key=True, index=True) # PK

#     cp_owner = relationship("Problems", back_populates="cproblem")
