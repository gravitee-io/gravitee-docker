import yaml
import requests
import os
import shutil

'''
:return a dict with the following structure
{
    "gitlab-fetcher": {
        "type": "fetcher"
        "version": "1.2.3"
        "url": "https://download.gravitee.io/graviteeio-apim/plugins/fetchers/gravitee-fetcher-gitlab/gravitee-fetcher-gitlab-1.2.3.zip",
        "url_tpl": "https://download.gravitee.io/graviteeio-apim/plugins/fetchers/gravitee-fetcher-gitlab/gravitee-fetcher-gitlab-{}.zip"
    },
    ...
}
'''
def load_official_plugins(type, version):
    plugins_root_url = "https://download.gravitee.io/graviteeio-{}/plugins".format(type.lower())
    url_prefix = {
        "fetcher": "{}/fetchers".format(plugins_root_url),
        "policy": "{}/policies".format(plugins_root_url),
        "reporter": "{}/reporters".format(plugins_root_url),
        "repository": "{}/repositories".format(plugins_root_url),
        "resource": "{}/resources".format(plugins_root_url)
    }
    releasejson_url = "https://raw.githubusercontent.com/gravitee-io/release/{}/release.json".format(version)
    print("Load official plugins descriptor from \n {}\n".format(releasejson_url))
    releasejson = requests.get(releasejson_url).json()
    plugins = {}
    for component in releasejson["components"]:
        if "plugins" in component.keys() is not None:
            for plugin in component["plugins"]:
                plugins[plugin["id"]] = {
                    "type": plugin["type"],
                    "version": component["version"],
                    "url": "{}/{}/{}-{}.zip".format(url_prefix[plugin["type"]], component["name"], component["name"], component["version"]),
                    "url_tpl": "{}/{}/{}-{{}}.zip".format(url_prefix[plugin["type"]], component["name"], component["name"]),
                }

    return plugins


def download(url):
    print("    Url: {}".format(url))
    local_filename = url.split('/')[-1]
    with requests.get(url, stream=True) as r:
        print("    Size: {}".format(r.headers['content-length']))
        with open(local_filename, 'wb') as f:
            shutil.copyfileobj(r.raw, f)
        print("    Done: {}\n".format(local_filename))
    return local_filename


def main():
    plugins_yaml = yaml.load(open("./plugins.yml", "r"))
    version = plugins_yaml["version"]
    type = plugins_yaml["type"].upper()
    plugins = plugins_yaml["plugins"]
    plugins_dir = os.environ.get('GRAVITEE_PLUGINS_INSTALLER_HOME')

    print("***********************************")
    print(" Graviteeio {}".format(type))
    print(" Version: {}".format(version))
    print(" Plugins: {}".format(len(plugins)))
    print(" Plugins dir: {}".format(plugins_dir))
    print("***********************************\n")

    plugins_descriptor = load_official_plugins(type, version)

    for plugin_id in plugins:
        print("PLUGIN: {}".format(plugin_id))
        if plugin_id.startswith("http://") or plugin_id.startswith("https://"):
            download(plugin_id)
        else:
            id_version = plugin_id.split(":")
            plugin = plugins_descriptor[id_version[0]]
            if len(id_version) == 1:
                download(plugin["url"])
            else:
                download(plugin["url_tpl"].format(id_version[1]))


main()
