from prefect import flow, task
import subprocess

@task
def dbt_seed():
    subprocess.run(
        ["dbt", "seed"],
        cwd=r"C:\Users\Juan Martí Sañudo\Desktop\Repo-demo\dbt\poc_dbt",
        check=True
    )

@task
def dbt_build():
    subprocess.run(
        ["dbt", "build"],
        cwd=r"C:\Users\Juan Martí Sañudo\Desktop\Repo-demo\dbt\poc_dbt",
        check=True
    )

@task
def dbt_docs():
    subprocess.run(
        ["dbt", "docs", "generate"],
        cwd=r"C:\Users\Juan Martí Sañudo\Desktop\Repo-demo\dbt\poc_dbt",
        check=True
    )

@flow
def dbt_pipeline():

    dbt_seed()

    dbt_build()

    dbt_docs()

if __name__ == "__main__":
    dbt_pipeline()