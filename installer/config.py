import yaml
import os

def parse_yaml(file_path):
    with open(file_path, 'r') as f:
        return yaml.safe_load(f)

def export_variables(config):
    for section, settings in config.items():
        if isinstance(settings, dict):
            for key, value in settings.items():
                # Convert to uppercase for shell variables
                var_name = key.upper()

                # Handle special cases
                if key == 'enabled_modules':
                    var_name = 'SENTINEL_MODULES_ENABLED'
                    value = ' '.join(value)
                elif key == 'lazy_load_modules':
                    var_name = 'SENTINEL_LAZY_LOAD_MODULES'
                    value = ' '.join(value)
                elif key == 'core_modules':
                    var_name = 'SENTINEL_CORE_MODULES'
                    value = ' '.join(value)
                elif section == 'ble':
                    var_name = f"BLESH_{key.upper()}"

                # Replace ~ with $HOME for shell compatibility
                if isinstance(value, str):
                    value = value.replace('~', '$HOME')

                print(f"export {var_name}='{value}'")

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
