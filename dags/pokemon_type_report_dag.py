from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime, timedelta

# Default arguments for the DAG
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'pokemon_type_report',
    default_args=default_args,
    description='Run pokemon_type_report.py with Airflow',
    schedule_interval=None,  # Change to a cron expression if scheduling is needed
    start_date=datetime(2025, 5, 4),
    catchup=False,
)

run_report = BashOperator(
    task_id='run_pokemon_type_report',
    bash_command='python3 /Users/leo/Desktop/Leo Kim/PokemonDB/pokemon_type_report.py',
    dag=dag,
)
