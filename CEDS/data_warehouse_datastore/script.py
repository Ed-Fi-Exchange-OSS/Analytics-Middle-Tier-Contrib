import pyodbc 
import json

# Databases connection string
def get_configuration():
    with open('./configuration.json', "r") as file:
        configuration = json.load(file)
    return configuration

# List of views
def get_views() -> list:
    with open('./views.json', "r") as file:
        views = json.load(file)
    return views

# Inserts dummy values into the data warehouse
def insert_dummy_values(config):
    conn_target = pyodbc.Connection
    try:
        print("Inserting dummy values...", end = '')
        conn_target = pyodbc.connect(
            f'Driver={"SQL Server"};Server={config["Target"]["Server"]};Database={config["Target"]["Database"]};Trusted_Connection={config["Target"]["Trusted_Connection"]};')
        
        with open('./dummy_values_inserts.sql','r') as file:
            sql_script = file.read()
            conn_target.execute(sql_script)
            conn_target.commit()
            conn_target.close()

        print ("Done!")

    except Exception as error:
        print (error)

# Transfer data
def transfer_data(view_info, config):
    conn_source = pyodbc.Connection
    conn_target = pyodbc.Connection
    mapping = []
    try: 
        conn_source = pyodbc.connect(
            f'Driver={"SQL Server"};Server={config["Source"]["Server"]};Database={config["Source"]["Database"]};Trusted_Connection={config["Source"]["Trusted_Connection"]};')
        
        conn_target = pyodbc.connect(
            f'Driver={"SQL Server"};Server={config["Target"]["Server"]};Database={config["Target"]["Database"]};Trusted_Connection={config["Target"]["Trusted_Connection"]};')

        cursor_source = conn_source.cursor()
        print (f"Querying {view_info['source_view']}...", end=' ')
        rows = cursor_source.execute(f"SELECT {view_info['select']} FROM {view_info['source_view']};").fetchall()

        for row in rows:
            key_field = row[0]
            row = row[1:]

            str_values = ''.join(['?,' for n in row])
            str_values = str_values[:len(str_values) - 1]

            if not view_info['target_fields']:
                view_info['target_fields'] = view_info['select']
            
            conn_target.execute(f"INSERT INTO {view_info['target_view']}({view_info['target_fields']}) VALUES ({str_values});", *row)
            cursor_target = conn_target.cursor()
            identity = int(cursor_target.execute(f"SELECT @@IDENTITY AS id;").fetchone()[0])
            
            mapping.append([identity,key_field])
            conn_target.commit()

        print ('Done!')
        return mapping

    except Exception as error:
        print (error)
        
    finally:
        conn_source.close()
        conn_target.close()
    
if __name__ == "__main__":
    key_mapping = {}
    config = get_configuration()
    insert_dummy_values(config)
    for view in get_views():
        rows = transfer_data(view, config)
        key_mapping[view['source_view']] = rows

    print (key_mapping["analytics.ceds_SchoolYearDim"])
        
