import click
import json
import math
import os
import pandas as pd

@click.group()
def cli():
    pass


# Parse file and generate a JSON schema
@click.command()
@click.argument('name')
def parse(name):
    file_path = os.path.abspath(name)

    f = pd.read_csv(file_path)
    data_type = f.dtypes.values
column_names = f.columns.values

    schema = {}
    features = []
    for ix in range(0, len(data_type)-1): 
        name = column_names[ix]
        feature_type = str(data_type[ix])
        completeness = (f.shape[0] - sum(f[name].isnull().values))/f.shape[0]

        if feature_type == 'object':
            domain = f[name].unique()
            domain = domain.tolist()

        if feature_type == 'float64' or feature_type == 'int64':
            min_value = f[name].min()
            max_value = f[name].max()
            
            if math.isnan(min_value) and math.isnan(max_value):
                domain = {'min': 'nan', 'max': 'nan'}
            else:
                 # .item() is added to convert numpy type to python type to avoid
                 # JSON serialization error
                domain = {'min': min_value.item(), 'max': max_value.item()}
        
        element = {'name': name, 
                   'type': feature_type,
                   'presence': 'REQUIRED',
                   'domain': domain,
                   'completeness': completeness} 
        features.append(element)
    
    schema['Response'] = []
    schema['Features'] = features
    

    with open(os.path.join(os.path.dirname(file_path), 'schema.json'), 'w') as outfile:
        json.dump(schema, outfile, sort_keys = False, indent=2)

    click.echo(click.style('Successfully processed %s features' % len(column_names), fg='green'))

validate

cli.add_command(parse)

if __name__ == '__main__':
    cli()
