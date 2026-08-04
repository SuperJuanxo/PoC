from prefect import flow, task, get_run_logger
import subprocess 
import duckdb


DBT_PATH = r"C:\Users\Juan Martí Sañudo\Desktop\Repo-demo\dbt\poc_dbt"




@task
def dbt_seed():
    logger = get_run_logger()    
    logger.info("Iniciando carga Seeds")
    subprocess.run(
        ["dbt", "seed"],
        cwd=DBT_PATH,
        check=True
    )
    logger.info("✅Seeds cargadas correctamente")

@task
def dbt_staging():
    
    logger = get_run_logger()    
    logger.info("Iniciando staging")
    subprocess.run(
        ["dbt", "run", "-s", "staging"],
        cwd=DBT_PATH,
        check=True
    )
    logger.info("✅Staging finalizó correctamente")

@task
def dbt_intermediate():
    logger = get_run_logger()    
    logger.info("Iniciando intermediate")
    subprocess.run(
        ["dbt", "run", "-s", "intermediate"],
        cwd=DBT_PATH,
        check=True
    )
    logger.info("✅Intermediate finalizó correctamente")

@task
def dbt_marts():
    logger = get_run_logger()    
    logger.info("Iniciando marts")
    subprocess.run(
        ["dbt", "run", "-s", "marts"],
        cwd=DBT_PATH,
        check=True
    )
    logger.info("✅Marts finalizó correctamente")

@task
def dbt_test():

    logger = get_run_logger()

    logger.info("Ejecutando controles de calidad")

    result = subprocess.run(
        ["dbt", "test"],
        cwd=DBT_PATH,
        capture_output=True,
        text=True
    )

    logger.info(result.stdout)
    con = duckdb.connect(DBT_PATH + r"\dev.duckdb")
    if result.returncode != 0:

        logger.error("❌ Se encontraron errores de calidad")

        filas = con.execute("""
            SELECT Soci, NIF, Situacio
            FROM stg__socis_completa
            WHERE Situacio NOT IN (0,1,2,3)
            OR NIF IS NULL
        """).fetchall()

        for socio, nif, situacio in filas:

            logger.error(f"""
                ❌ Registro inválido detectado

                Socio    : {socio}
                NIF      : {nif}
                Situacio : {situacio}

                Reglas incumplidas:
                - NIF no puede ser NULL
                - Situacio debe pertenecer a [0,1,2,3]
                """)

        raise Exception(
            f"Se encontraron {len(filas)} registros inválidos"
        )
    con.close()

    logger.info("✅ Todos los tests han superado las validaciones")

@task
def dbt_build():

    logger = get_run_logger()

    logger.info("Ejecutando build")
    subprocess.run(
        ["dbt", "build"],
        cwd=DBT_PATH,
        check=True
    )
    logger.info("✅ Build hecho")
@task
def dbt_docs():

    logger = get_run_logger()

    logger.info("Generando documentación de dbt")
    subprocess.run(
        ["dbt", "docs", "generate"],
        cwd=DBT_PATH,
        check=True
    )
    logger.info("✅ Documentación generada")

@flow(name="dbt_steps")
def dbt_pipeline():

    dbt_seed()

    dbt_staging()

    dbt_intermediate()

    dbt_marts()

    dbt_docs()

    dbt_test()


if __name__ == "__main__":
    dbt_pipeline()