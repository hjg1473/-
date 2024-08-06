import enum
from sqlalchemy import JSON, Boolean, Column, Integer, String, ForeignKey, Table
from sqlalchemy.orm import relationship
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

# 중간 테이블 정의
correct_problem_table = Table('correct_problem', Base.metadata,
    Column('study_info_id', Integer, ForeignKey('studyInfo.id')),
    Column('problem_id', Integer, ForeignKey('problems.id')),
    Column('count', Integer, nullable=False, default=1),
    Column('isGroup', Integer, nullable=False, default=0)
)

incorrect_problem_table = Table('incorrect_problem', Base.metadata,
    Column('study_info_id', Integer, ForeignKey('studyInfo.id')),
    Column('problem_id', Integer, ForeignKey('problems.id')),
    Column('count', Integer, nullable=False, default=1),
    Column('isGroup', Integer, nullable=False, default=0)
)

# Association table for many-to-many relationship between students and teachers
student_teacher_table = Table('student_teacher', Base.metadata,
    Column('teacher_id', Integer, ForeignKey('users.id')),
    Column('student_id', Integer, ForeignKey('users.id'))
)

teacher_group_table = Table('teacher_group', Base.metadata,
    Column('teacher_id', Integer, ForeignKey('users.id')),
    Column('group_id', Integer, ForeignKey('groups.id'))
)

class Users(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)  # PK, auto-increment
    username = Column(String(100), unique=True, index=True)  # Unique username
    hashed_password = Column(String(100))  # Hashed password
    name = Column(String(100))  # Real name
    role = Column(String(100), index=True)  # Role (super or student or parent)
    question = Column(String(100))
    questionType = Column(Integer)
    released_season = Column(JSON)  # Unique token (teachers only) > released_season

    # Relationship with Groups
    team_id = Column(Integer, ForeignKey("groups.id"), nullable=True) # FK, team (student only)
    team = relationship("Groups", foreign_keys=[team_id], back_populates="members")

    # Relationship with StudyInfo
    studyInfos = relationship("StudyInfo", back_populates="owner",cascade='delete')
    released = relationship("Released", back_populates="owner",cascade='delete')
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


class Released(Base):  # Study information
    __tablename__ = "released"

    id = Column(Integer, primary_key=True, index=True)  # PK
    released_season = Column(Integer, default=1)
    released_level = Column(Integer, default=1)
    released_step = Column(Integer, default=1)
    owner_id = Column(Integer, ForeignKey("users.id"))  # FK to users

    # Relationships
    owner = relationship("Users", back_populates="released")

class Groups(Base):
    __tablename__ = "groups"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100))
    grade = Column(String(100))
    members = relationship("Users", foreign_keys=[Users.team_id], back_populates="team")

class WrongType(Base):
    __tablename__ = "wrongType"

    id = Column(Integer, primary_key=True, index=True)
    season = Column(Integer)
    level = Column(Integer)

    wrong_letter = Column(Integer, default=0)
    wrong_punctuation = Column(Integer, default=0)
    wrong_block = Column(Integer, default=0)
    wrong_order = Column(Integer, default=0)
    wrong_word = Column(Integer, default=0)

    info_id = Column(Integer, ForeignKey("studyInfo.id"))  # FK to study Info
    info = relationship("StudyInfo", back_populates="wrong_types", cascade="delete") # 1:M to study info


class StudyInfo(Base):  # Study information
    __tablename__ = "studyInfo"

    id = Column(Integer, primary_key=True, index=True)  # PK
    totalStudyTime = Column(Integer)  # Student Type1 level >> stream_study_day
    streamStudyDay = Column(Integer)  # Student Type2 level >> total_study_time
    owner_id = Column(Integer, ForeignKey("users.id"))  # FK to users

    # Relationships
    owner = relationship("Users", back_populates="studyInfos", cascade="delete")
    correct_problems = relationship("Problems", secondary=correct_problem_table, back_populates="correct_study_infos")
    incorrect_problems = relationship("Problems", secondary=incorrect_problem_table, back_populates="incorrect_study_infos")
    wrong_types = relationship("WrongType", back_populates="info", cascade="delete")

class Problems(Base):  # Problems
    __tablename__ = "problems"

    id = Column(Integer, primary_key=True, index=True)  # PK
    season = Column(String(100))  # Season
    level = Column(Integer)  # Type >> level
    step = Column(Integer)  # Problem level (1-3)>> step
    koreaProblem = Column(String(100))  # Korean sentence
    englishProblem = Column(String(100))  # English sentence
    img_path = Column(String(100))  # Problem image (optional)
    type = Column(String(100)) # normal or ai
    difficulty = Column(Integer)

    # Relationships
    correct_study_infos = relationship("StudyInfo", secondary=correct_problem_table, back_populates="correct_problems")
    incorrect_study_infos = relationship("StudyInfo", secondary=incorrect_problem_table, back_populates="incorrect_problems")

class Blocks(Base):
    __tablename__ = "blocks"

    id = Column(Integer, primary_key=True, index=True)  # PK
    color = Column(String(100))      # color: skyblue, pink, green, yellow, purple

    word = relationship("Words", back_populates="block")#,cascade='delete')

class Words(Base):
    __tablename__ = "words"

    id = Column(Integer, primary_key=True, index=True)  # PK
    block_id = Column(Integer, ForeignKey("blocks.id"))  # FK
    block = relationship("Blocks", back_populates="word")
    
    words = Column(String(100))      # word value: I, me, dog, ...