import yaml
import os

def parse_yaml(file_path):
    with open(file_path, 'r') as f:
        return yaml.safe_load(f)

def export_variables(config, prefix=''):
    for key, value in config.items():
        new_prefix = f"{prefix}{key}_".upper()
        if isinstance(value, dict):
            export_variables(value, new_prefix)
        else:
            # Replace ~ with $HOME for shell compatibility
            if isinstance(value, str):
                value = value.replace('~', '$HOME')
            print(f"export {new_prefix[:-1]}='{value}'")

def main():
    config_file = 'config.yaml'
    dist_config_file = 'config.yaml.dist'

    if os.path.exists(config_file):
        config = parse_yaml(config_file)
    elif os.path.exists(dist_config_file):
        config = parse_yaml(dist_config_file)
    else:
        print("echo 'Configuration file not found.' >&2")
        exit(1)

    export_variables(config)

if __name__ == "__main__":
    main()
