from sqlalchemy import Column, Integer, String, ForeignKey, Table
from sqlalchemy.orm import relationship
from database import Base

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
    phone_number = Column(String) # phone_number (teachers only)
    idToken = Column(String)  # Unique token (teachers only)

    # Relationship with Groups
    team_id = Column(Integer, ForeignKey("groups.id"), nullable=True) # FK, team (student only)
    team = relationship("Groups", foreign_keys=[team_id], back_populates="members")

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
