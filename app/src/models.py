import enum
from sqlalchemy import JSON, Boolean, Column, Integer, String, ForeignKey, Table
from sqlalchemy.orm import relationship
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

# 중간 테이블 정의
correct_problem_table = Table('correct_problem', Base.metadata,
    Column('study_info_id', Integer, ForeignKey('studyInfo.id')),
    Column('problem_id', Integer, ForeignKey('problems.id')),
    Column('count', Integer, nullable=False, default=1)
)

incorrect_problem_table = Table('incorrect_problem', Base.metadata,
    Column('study_info_id', Integer, ForeignKey('studyInfo.id')),
    Column('problem_id', Integer, ForeignKey('problems.id')),
    Column('count', Integer, nullable=False, default=1)
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
    username = Column(String, unique=True, index=True)  # Unique username
    hashed_password = Column(String)  # Hashed password
    name = Column(String)  # Real name
    role = Column(String, index=True)  # Role (super or student or parent)
    question = Column(String)
    questionType = Column(Integer)
    released_season = Column(JSON)  # Unique token (teachers only) > released_season

    # Relationship with Groups
    team_id = Column(Integer, ForeignKey("groups.id"), nullable=True) # FK, team (student only)
    team = relationship("Groups", foreign_keys=[team_id], back_populates="members")

    # Relationship with StudyInfo
    studyInfos = relationship("StudyInfo", back_populates="owner",cascade='delete')

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
    grade = Column(String)
    releasedLevel = Column(Integer, default=1)
    releasedStep = Column(Integer, default=1)
    # admin_id = Column(Integer, ForeignKey("users.id")) # FK, teacher_id

    # owner = relationship("Users", foreign_keys=[admin_id], back_populates="managed_groups")
    members = relationship("Users", foreign_keys=[Users.team_id], back_populates="team")

# Relationship definition in Users for Groups
# Users.managed_groups = relationship("Groups", foreign_keys=[Groups.admin_id], back_populates="owner")

class StudyInfo(Base):  # Study information
    __tablename__ = "studyInfo"

    id = Column(Integer, primary_key=True, index=True)  # PK
    totalStudyTime = Column(Integer)  # Student Type1 level >> stream_study_day
    streamStudyDay = Column(Integer)  # Student Type2 level >> total_study_time
    releasedLevel = Column(Integer, default=1)  # Student Type3 level >> released_level, the highest level that the student can solve.
    releasedStep = Column(Integer, default=1)
    owner_id = Column(Integer, ForeignKey("users.id"))  # FK to users

    wrong_letter = Column(Integer, default=0)
    wrong_punctuation = Column(Integer, default=0)
    wrong_block = Column(Integer, default=0)
    wrong_order = Column(Integer, default=0)
    wrong_word = Column(Integer, default=0)

    # Relationships
    owner = relationship("Users", back_populates="studyInfos")
    correct_problems = relationship("Problems", secondary=correct_problem_table, back_populates="correct_study_infos")
    incorrect_problems = relationship("Problems", secondary=incorrect_problem_table, back_populates="incorrect_study_infos")

class Problems(Base):  # Problems
    __tablename__ = "problems"

    id = Column(Integer, primary_key=True, index=True)  # PK
    season = Column(String)  # Season
    level = Column(Integer)  # Type >> level
    step = Column(Integer)  # Problem level (1-3)>> step
    koreaProblem = Column(String)  # Korean sentence
    englishProblem = Column(String)  # English sentence
    img_path = Column(String)  # Problem image (optional)
    type = Column(String) # normal or ai
    difficulty = Column(Integer)

    # Relationships
    correct_study_infos = relationship("StudyInfo", secondary=correct_problem_table, back_populates="correct_problems")
    incorrect_study_infos = relationship("StudyInfo", secondary=incorrect_problem_table, back_populates="incorrect_problems")

class Blocks(Base):
    __tablename__ = "blocks"

    id = Column(Integer, primary_key=True, index=True)  # PK
    color = Column(String)      # color: skyblue, pink, green, yellow, purple

    word = relationship("Words", back_populates="block")#,cascade='delete')

class Words(Base):
    __tablename__ = "words"

    id = Column(Integer, primary_key=True, index=True)  # PK
    block_id = Column(Integer, ForeignKey("blocks.id"))  # FK
    block = relationship("Blocks", back_populates="word")
    
    words = Column(String)      # word value: I, me, dog, ...