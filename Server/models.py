import enum
from sqlalchemy import Boolean, Column, Integer, String, ForeignKey, Table
from sqlalchemy.orm import relationship
from database import Base
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship, sessionmaker

# 중간 테이블 정의
correct_problem_table = Table('correct_problem', Base.metadata,
    Column('study_info_id', Integer, ForeignKey('studyInfo.id')),
    Column('problem_id', Integer, ForeignKey('problems.id'))
)

incorrect_problem_table = Table('incorrect_problem', Base.metadata,
    Column('study_info_id', Integer, ForeignKey('studyInfo.id')),
    Column('problem_id', Integer, ForeignKey('problems.id'))
)
# Association table for many-to-many relationship between students and teachers
student_teacher_table = Table('student_teacher', Base.metadata,
    Column('teacher_id', Integer, ForeignKey('users.id')),
    Column('student_id', Integer, ForeignKey('users.id'))
)

class Users(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)  # PK, auto-increment
    username = Column(String, unique=True, index=True)  # Unique username
    hashed_password = Column(String)  # Hashed password
    email = Column(String, unique=True, index=True)  # Email (teachers only)
    name = Column(String)  # Real name
    age = Column(Integer)  # Age
    role = Column(String, index=True)  # Role (super or student)
    group = Column(Integer)  # Group (students only)
    phone_number = Column(String) # phone_number (teachers only)
    idToken = Column(String)  # Unique token (teachers only)   

    # Relationship with Groups
    team_id = Column(Integer, ForeignKey("groups.id"), nullable=True) # FK, team (student only)
    team = relationship("Groups", foreign_keys=[team_id], back_populates="members")

    # Relationship with StudyInfo
    studyInfos = relationship("StudyInfo", back_populates="owner")

    # Many-to-many relationship between students and teachers
    student_teachers = relationship(
        "Users",
        secondary=student_teacher_table,
        primaryjoin=(id == student_teacher_table.c.teacher_id),
        secondaryjoin=(id == student_teacher_table.c.student_id),
        back_populates="teachers_students",
        foreign_keys=[student_teacher_table.c.teacher_id, student_teacher_table.c.student_id],
        lazy='subquery'
    )
    teachers_students = relationship(
        "Users",
        secondary=student_teacher_table,
        primaryjoin=(id == student_teacher_table.c.student_id),
        secondaryjoin=(id == student_teacher_table.c.teacher_id),
        back_populates="student_teachers",
        foreign_keys=[student_teacher_table.c.student_id, student_teacher_table.c.teacher_id],
        lazy='subquery'
    )

class Groups(Base):
    __tablename__ = "groups"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)
    admin_id = Column(Integer, ForeignKey("users.id")) # FK, teacher_id

    owner = relationship("Users", foreign_keys=[admin_id], back_populates="managed_groups")
    members = relationship("Users", foreign_keys=[Users.team_id], back_populates="team")

# Relationship definition in Users for Groups
Users.managed_groups = relationship("Groups", foreign_keys=[Groups.admin_id], back_populates="owner")

class StudyInfo(Base):  # Study information
    __tablename__ = "studyInfo"

    id = Column(Integer, primary_key=True, index=True)  # PK
    stdLevel = Column(Integer)  # Student level
    owner_id = Column(Integer, ForeignKey("users.id"))  # FK to users

    # Relationships
    owner = relationship("Users", back_populates="studyInfos")
    # correct_problems = relationship("Problems", foreign_keys='Problems.TStudyInfo_id', back_populates="correct_study_info")
    # incorrect_problems = relationship("Problems", foreign_keys='Problems.FStudyInfo_id', back_populates="incorrect_study_info")
    correct_problems = relationship("Problems", secondary=correct_problem_table, back_populates="correct_study_infos")
    incorrect_problems = relationship("Problems", secondary=incorrect_problem_table, back_populates="incorrect_study_infos")

class Problems(Base):  # Problems
    __tablename__ = "problems"

    id = Column(Integer, primary_key=True, index=True)  # PK
    season = Column(String)  # Season
    type = Column(String)  # Type
    problemLevel = Column(Integer)  # Problem level (1-3)
    koreaProblem = Column(String)  # Korean sentence
    englishProblem = Column(String)  # English sentence
    img_path = Column(String)  # Problem image (optional)
    # StudyInfo_id 가 갖는 id 값은 StudyInfo.id 값.
    # 동일 문제에서, 민수(id=1)도 이 문제를 맞추고, 철수(id=2)도 이 문제를 맞추면 TStudyInfo_id 에는 [1, 2] 가 들어가야 됨.
    # TStudyInfo_id = Column(Integer, ForeignKey("studyInfo.id"))  # FK to correct study info 
    # FStudyInfo_id = Column(Integer, ForeignKey("studyInfo.id"))  # FK to incorrect study info
    cproblem_id = Column(Integer, ForeignKey("customProblemSet.id"))  # FK to custom problem set

    # # Relationships
    # correct_study_info = relationship("StudyInfo", foreign_keys=[TStudyInfo_id], back_populates="correct_problems")
    # incorrect_study_info = relationship("StudyInfo", foreign_keys=[FStudyInfo_id], back_populates="incorrect_problems")
    correct_study_infos = relationship("StudyInfo", secondary=correct_problem_table, back_populates="correct_problems")
    incorrect_study_infos = relationship("StudyInfo", secondary=incorrect_problem_table, back_populates="incorrect_problems")
    custom_problem_set = relationship("CustomProblemSet", foreign_keys=[cproblem_id], back_populates="problems")

class CustomProblemSet(Base):  # Custom problem set
    __tablename__ = "customProblemSet"

    id = Column(Integer, primary_key=True, index=True)  # PK

    # Relationship
    problems = relationship("Problems", back_populates="custom_problem_set")