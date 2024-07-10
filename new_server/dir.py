import os

# 디렉토리 구조
directories = [
    "fastapi-project/alembic/",
    "fastapi-project/src/auth",
    "fastapi-project/src/aws",
    "fastapi-project/src/posts",
    "fastapi-project/tests/auth",
    "fastapi-project/tests/aws",
    "fastapi-project/tests/posts",
    "fastapi-project/templates/",
    "fastapi-project/requirements/"
]

# 파일 구조
files = {
    "fastapi-project/src/auth": ["router.py", "schemas.py", "models.py", "dependencies.py", "config.py", "constants.py", "exceptions.py", "service.py", "utils.py"],
    "fastapi-project/src/aws": ["client.py", "schemas.py", "config.py", "constants.py", "exceptions.py", "utils.py"],
    "fastapi-project/src/posts": ["router.py", "schemas.py", "models.py", "dependencies.py", "constants.py", "exceptions.py", "service.py", "utils.py"],
    "fastapi-project/src": ["config.py", "models.py", "exceptions.py", "pagination.py", "database.py", "main.py"],
    "fastapi-project/requirements": ["base.txt", "dev.txt", "prod.txt"],
    "fastapi-project/templates": ["index.html"],
    "fastapi-project": [".env", ".gitignore", "logging.ini", "alembic.ini"]
}

def create_directories(directories):
    for directory in directories:
        os.makedirs(directory, exist_ok=True)
        print(f"Created directory: {directory}")

def create_files(files):
    for directory, file_list in files.items():
        for file_name in file_list:
            file_path = os.path.join(directory, file_name)
            with open(file_path, 'w') as file:
                file.write("")  # 빈 파일 생성
            print(f"Created file: {file_path}")

if __name__ == "__main__":
    create_directories(directories)
    create_files(files)
    print("Directory structure created successfully.")