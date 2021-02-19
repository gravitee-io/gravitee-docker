import os
import re
import shutil
import zipfile
import requests
import json
from shutil import copy2
from urllib.request import urlretrieve
import urllib
import http.client
# import urllib2, base64
from urllib.request import urlopen
from shutil import copyfileobj
import requests
import getpass

# ----
http.client.HTTPConnection.debuglevel = 1

# from urllib.request import urlopen
# from shutil import copyfileobj

# with urlopen(my_url) as in_stream, open('my_filename', 'wb') as out_file:
#     copyfileobj(in_stream, out_file)


# ---

arti_username_param = os.environ.get('ARTIFACTORY_USERNAME')
arti_password_param = os.environ.get('ARTIFACTORY_PASSWORD')
# artifactory_repo = "nexus-and-non-dry-run-releases"
# artifactory_repo = "gravitee-releases"
artifactory_repo = os.environ.get('ARTIFACTORY_REPO_NAME')
https_debug_level = os.environ.get('HTTPS_DEBUG_LEVEL')

# create a password manager
password_mgr = urllib.request.HTTPPasswordMgrWithDefaultRealm()

# Add the username and password.
# If we knew the realm, we could use it instead of None.
# https://odbxikk7vo-artifactory.services.clever-cloud.com/gravitee-releases/releases/io/gravitee/portal/gravitee-portal-webui/3.4.3/gravitee-portal-webui-3.4.3.zip
# for portal, for example,the zip is fetched form artifactory:
# => search in gravitee-releases repo
# => if not found in gravitee-releases repo, then fetch the [nexus-and-non-dry-run-releases/] repo (https://odbxikk7vo-artifactory.services.clever-cloud.com/nexus-and-non-dry-run-releases/)
#    and in each artifactory repo, the URL of the GRavitee APIM Portal, relatively to the artifactory repo URL, is [/io/gravitee/portal/gravitee-portal-webui/3.4.3/gravitee-portal-webui-3.4.3.zip]

# top_level_url = "http://example.com/foo/"

# artifactory_repo_url = "https://odbxikk7vo-artifactory.services.clever-cloud.com/" + artifactory_repo + "/"
artifactory_repo_url = "https://odbxikk7vo-artifactory.services.clever-cloud.com/" + artifactory_repo


password_mgr.add_password(None, artifactory_repo_url, arti_username_param, arti_password_param)

handler = urllib.request.HTTPBasicAuthHandler(password_mgr)
https_handler = urllib.request.HTTPSHandler(debuglevel=1)
# create "opener" (OpenerDirector instance)
opener = urllib.request.build_opener(handler, https_handler)

# # use the opener to fetch a URL
# opener.open(a_url)

# # Install the opener.
# # Now all calls to urllib.request.urlopen use our opener.
urllib.request.install_opener(opener)
# ---
# So in functions I will use the below [urlopen] call to
# download a file, with a URL realtive to base URL defined by [artifactory_repo_url]
# ---
# with urlopen(my_url) as in_stream, open('my_filename', 'wb') as out_file:
#     copyfileobj(in_stream, out_file)

# - UNDER TESTS - #


















# ----
# ---- BEGINING OF LEGACY PYTHON SCRIPT
# ----

# Input parameters
version_param = os.environ.get('RELEASE_VERSION')
is_latest_param = True if version_param == "master" else False

# build constants
m2repo_path = '/m2repo'
# tmp_path = './tmp/%s' % version_param

# tmp_path = os.path.dirname(os.path.abspath(__file__)) + '/tmp/%s' % version_param
folder_for_all_downloaded_files = os.environ.get('FOLDER_FOR_ALL_DOWNLOADED_FILES')
tmp_path = folder_for_all_downloaded_files + '/tmp/%s' % version_param

current_dir_path = os.path.dirname(os.path.realpath(__file__))
jbl_py_system_path = os.environ.get('PATH');

print('\nTemporary Folfer is : %s' % (tmp_path))
policies_path = "%s/policies" % tmp_path
resources_path = "%s/resources" % tmp_path
fetchers_path = "%s/fetchers" % tmp_path
services_path = "%s/services" % tmp_path
reporters_path = "%s/reporters" % tmp_path
repositories_path = "%s/repositories" % tmp_path
snapshotPattern = re.compile('.*-SNAPSHOT')


def clean():
    if os.path.exists(tmp_path):
        shutil.rmtree(tmp_path)
    os.makedirs(tmp_path, exist_ok=True)
    os.makedirs(policies_path, exist_ok=True)
    os.makedirs(fetchers_path, exist_ok=True)
    os.makedirs(resources_path, exist_ok=True)
    os.makedirs(services_path, exist_ok=True)
    os.makedirs(reporters_path, exist_ok=True)
    os.makedirs(repositories_path, exist_ok=True)


def get_policies(release_json):
    components = release_json['components']
    search_pattern = re.compile('gravitee-policy-.*')
    policies = []
    for component in components:
        if search_pattern.match(component['name']) and 'gravitee-policy-api' != component['name']:
            policies.append(component)
            if "gravitee-policy-ratelimit" == component['name']:
                policies.append({"name": "gravitee-policy-quota", "version": component['version']})
                if int(component['version'].replace(".", "").replace("-SNAPSHOT", "")) >= 1100:
                    policies.append({"name": "gravitee-policy-spikearrest", "version": component['version']})
    return policies


def get_resources(release_json):
    components_name = [
        "gravitee-resource-cache",
        "gravitee-resource-oauth2-provider-generic",
        "gravitee-resource-oauth2-provider-am"
    ]
    resources = []
    for component_name in components_name:
        resources.append(get_component_by_name(release_json, component_name))
    return resources

def get_fetchers(release_json):
    components = release_json['components']
    search_pattern = re.compile('gravitee-fetcher-.*')
    fetchers = []
    for component in components:
        if search_pattern.match(component['name']) and 'gravitee-fetcher-api' != component['name']:
            fetchers.append(component)
    return fetchers


def get_reporters(release_json):
    components_name = [
        "gravitee-reporter-file",
        "gravitee-elasticsearch"
    ]
    reporters = []
    for component_name in components_name:
        reporters.append(get_component_by_name(release_json, component_name))
    return reporters


def get_repositories(release_json):
    components_name = [
        "gravitee-repository-mongodb",
        "gravitee-repository-jdbc",
        "gravitee-elasticsearch",
        "gravitee-repository-gateway-bridge-http"
    ]
    repositories = []
    for component_name in components_name:
        repositories.append(get_component_by_name(release_json, component_name))
    return repositories


def get_services(release_json):
    components_name = [
        "gravitee-service-discovery-consul"
    ]
    components = release_json['components']
    search_pattern = re.compile('gravitee-policy-ratelimit')
    services = []
    for component in components:
        if search_pattern.match(component['name']):
            service = component.copy()
            service['name'] = 'gravitee-gateway-services-ratelimit'
            services.append(service)
            break

    for component_name in components_name:
        services.append(get_component_by_name(release_json, component_name))

    return services


def get_component_by_name(release_json, component_name):
    components = release_json['components']
    search_pattern = re.compile(component_name)
    for component in components:
        if search_pattern.match(component['name']):
            return component


def get_download_url(group_id, artifact_id, version, t):
    m2path = "%s/%s/%s/%s/%s-%s.%s" % (m2repo_path, group_id.replace(".", "/"), artifact_id, version, artifact_id, version, t)
    if os.path.exists(m2path):
        return m2path
    else:
        # https://odbxikk7vo-artifactory.services.clever-cloud.com/gravitee-releases/com/graviteesource/license/gravitee-license-api/1.1.2/gravitee-license-api-1.1.2.jar
        # return "https://oss.sonatype.org/service/local/repositories/%s/content/%s/%s/%s/%s-%s.%s" % (
        # return artifactory_repo_url + "/%s/%s/%s/%s/%s-%s.%s" % (
            # ("snapshots" if snapshotPattern.match(version) else "releases"), group_id.replace(".", "/"), artifact_id, version, artifact_id, version, t)
        return artifactory_repo_url + "/%s/%s/%s/%s-%s.%s" % (
            group_id.replace(".", "/"), artifact_id, version, artifact_id, version, t)


def get_suffix_path_by_name(name):
    if name.find("policy") == -1:
        suffix = name[name.find('-') + 1:name.find('-', name.find('-') + 1)]
        if suffix == "gateway":
            return "services"
        if suffix == "repository":
            return "repositories"
        return suffix + "s"
    else:
        return "policies"


def download(name, filename_path, url):
    print('\nDowloading %s\n%s' % (name, url))
    if url.startswith("http"):
        filename_path = tmp_path + "/" + get_suffix_path_by_name(name) + url[url.rfind('/'):]
        target_folder_path = tmp_path + "/" + get_suffix_path_by_name(name)
        print('\nJBL Voici l\'URL téléchargée et le folder local de destination dans le legacy :  %s\n%s' % (url, filename_path))
        print('\nJBL Voici l\'URL téléchargée et le folder local de destination dans le code JBL :  %s\n%s' % (url, target_folder_path))
        print('\n current linux user is : %s\n' % getpass.getuser())
        print('\n current_dir_path is: %s\n' % current_dir_path)
        print('\n system PATH is: %s\n' % jbl_py_system_path)
        # with urllib.request.urlopen(url) as in_stream, open(filename_path, 'wb') as out_file:
            # shutil.copyfileobj(in_stream.read(), out_file, -1)
            # # out_file.write(in_stream.read())
        # print('Writing extremely simple testfile')
        if not os.path.isdir(target_folder_path):
          os.mkdir(target_folder_path)
        print('Beginning file download with requests')
        # r = requests.get(url)
        r = requests.get(url, auth=(arti_username_param, arti_password_param))

        with open(filename_path, 'wb+') as f:
            f.write(r.content)

        # Retrieve HTTP meta-data
        print(r.status_code)
        print(r.headers['content-type'])
        print(r.encoding)

    else:
        copy2(url, filename_path)

    print('\nDowloaded in %s' % filename_path)
    return filename_path


def unzip(files):
    unzip_dirs = []
    dist_dir = get_dist_dir_name()
    for file in files:
        with zipfile.ZipFile(file) as zip_file:
            zip_file.extractall("%s/%s" % (tmp_path, dist_dir))
            unzip_dir = "%s/%s/%s" % (tmp_path, dist_dir, sorted(zip_file.namelist())[0])
            unzip_dirs.append(unzip_dir)
            preserve_permissions(unzip_dir)
    return sorted(unzip_dirs)


def preserve_permissions(d):
    search_bin_pattern = re.compile(".*/bin$")
    search_gravitee_pattern = re.compile("gravitee(\.bat)?")
    perm = 0o0755
    for dirname, subdirs, files in os.walk(d):
        if search_bin_pattern.match(dirname):
            for file in files:
                if search_gravitee_pattern.match(file):
                    file_path = "%s/%s" % (dirname, file)
                    print("       set permission %o to %s" % (perm, file_path))
                    os.chmod(file_path, perm)


def copy_files_into(src_dir, dest_dir, exclude_pattern=None):
    if exclude_pattern is None:
        exclude_pattern = []
    filenames = [os.path.join(src_dir, fn) for fn in next(os.walk(src_dir))[2]]

    print("        copy")
    print("            %s" % filenames)
    print("        into")
    print("            %s" % dest_dir)
    for file in filenames:
        to_exclude = False
        for pattern in exclude_pattern:
            search_pattern = re.compile(pattern)
            if search_pattern.match(file):
                to_exclude = True
                break
        if to_exclude:
            print("[INFO] %s is excluded from files." % file)
            continue
        copy2(file, dest_dir)


def download_policies(policies):
    paths = []
    for policy in policies:
        if policy['name'] != "gravitee-policy-core":
            url = get_download_url("io.gravitee.policy", policy['name'], policy['version'], "zip")
            print("-------------------------")
            print("url calculée par jbl : ")
            print("-------------------------")
            print(url)
            print("-------------------------")
            paths.append(
                download(policy['name'], '%s/%s-%s.zip' % (policies_path, policy['name'], policy['version']), url))
    return paths


def download_management_api(mgmt_api, default_version):
    v = default_version if 'version' not in mgmt_api else mgmt_api['version']
    url = get_download_url("io.gravitee.management.standalone", "gravitee-management-api-standalone-distribution-zip",
                           v, "zip")
    print("-------------------------")
    print("url calculée par jbl : ")
    print("-------------------------")
    print(url)
    print("-------------------------")
    return download(mgmt_api['name'], '%s/%s-%s.zip' % (tmp_path, mgmt_api['name'], v), url)


def download_managementV3_api(mgmt_api, default_version):
    v = default_version if 'version' not in mgmt_api else mgmt_api['version']
    url = get_download_url("io.gravitee.rest.api.standalone.distribution", "gravitee-rest-api-standalone-distribution-zip",
                           v, "zip")
    print("-------------------------")
    print("url calculée par jbl : ")
    print("-------------------------")
    print(url)
    print("-------------------------")
    return download(mgmt_api['name'], '%s/%s-%s.zip' % (tmp_path, mgmt_api['name'], v), url)


def download_gateway(gateway, default_version):
    v = default_version if 'version' not in gateway else gateway['version']
    url = get_download_url("io.gravitee.gateway.standalone", "gravitee-gateway-standalone-distribution-zip",
                    v, "zip")
    print("-------------------------")
    print("url calculée par jbl : ")
    print("-------------------------")
    print(url)
    print("-------------------------")
    return download(gateway['name'], '%s/%s-%s.zip' % (tmp_path, gateway['name'], v), url)


def download_fetchers(fetchers):
    paths = []
    for fetcher in fetchers:
        url = get_download_url("io.gravitee.fetcher", fetcher['name'], fetcher['version'], "zip")
        paths.append(
            download(fetcher['name'], '%s/%s-%s.zip' % (fetchers_path, fetcher['name'], fetcher['version']), url))
        print("-------------------------")
        print("url calculée par jbl : ")
        print("-------------------------")
        print(url)
        print("-------------------------")
    return paths


def download_resources(resources):
    paths = []
    for resource in resources:
        url = get_download_url("io.gravitee.resource", resource['name'], resource['version'], "zip")
        print("-------------------------")
        print("url calculée par jbl : ")
        print("-------------------------")
        print(url)
        print("-------------------------")
        paths.append(
            download(resource['name'], '%s/%s-%s.zip' % (resources_path, resource['name'], resource['version']), url))
    return paths


def download_services(services):
    paths = []
    for service in services:
        # for release < 1.22
        if service is not None:
            if service['name'] == "gravitee-gateway-services-ratelimit":
                url = get_download_url("io.gravitee.policy", service['name'], service['version'], "zip")
            else:
                url = get_download_url("io.gravitee.discovery", service['name'], service['version'], "zip")
            print("-------------------------")
            print("url calculée par jbl : ")
            print("-------------------------")
            print(url)
            print("-------------------------")
            paths.append(
                download(service['name'], '%s/%s-%s.zip' % (services_path, service['name'], service['version']), url))
    return paths


def download_ui(ui, default_version):
    v = default_version if 'version' not in ui else ui['version']
    url = get_download_url("io.gravitee.management", ui['name'], v, "zip")
    print("-------------------------")
    print("url calculée par jbl : ")
    print("-------------------------")
    print(url)
    print("-------------------------")
    return download(ui['name'], '%s/%s-%s.zip' % (tmp_path, ui['name'], v), url)


def download_portal_ui(ui, default_version):
    v = default_version if 'version' not in ui else ui['version']
    url = get_download_url("io.gravitee.portal", ui['name'], v, "zip")
    print("-------------------------")
    print("url calculée par jbl : ")
    print("-------------------------")
    print(url)
    print("-------------------------")
    return download(ui['name'], '%s/%s-%s.zip' % (tmp_path, ui['name'], v), url)


def download_reporters(reporters):
    paths = []
    for reporter in reporters:
        name = "gravitee-reporter-elasticsearch" if "gravitee-elasticsearch" == reporter['name'] else reporter['name']

        url = get_download_url("io.gravitee.reporter", name, reporter['version'], "zip")
        print("-------------------------")
        print("url calculée par jbl : ")
        print("-------------------------")
        print(url)
        print("-------------------------")
        paths.append(
            download(name, '%s/%s-%s.zip' % (reporters_path, name, reporter['version']), url))
    return paths


def download_repositories(repositories):
    paths = []
    for repository in repositories:
        if repository['name'] != "gravitee-repository-gateway-bridge-http":
            name = "gravitee-repository-elasticsearch" if "gravitee-elasticsearch" == repository['name'] else repository['name']
            url = get_download_url("io.gravitee.repository", name, repository['version'], "zip")
            print("-------------------------")
            print("url calculée par jbl : ")
            print("-------------------------")
            print(url)
            print("-------------------------")
            paths.append(download(name, '%s/%s-%s.zip' % (repositories_path, name, repository['version']), url))
        else:
            for name in ["gravitee-repository-gateway-bridge-http-client", "gravitee-repository-gateway-bridge-http-server"]:
                url = get_download_url("io.gravitee.gateway", name, repository['version'], "zip")
                print("-------------------------")
                print("url calculée par jbl : ")
                print("-------------------------")
                print(url)
                print("-------------------------")
                paths.append(download(name, '%s/%s-%s.zip' % (repositories_path, name, repository['version']), url))
    return paths


def prepare_gateway_bundle(gateway):
    print("==================================")
    print("Prepare %s" % gateway)
    bundle_path = unzip([gateway])[0]
    print("        bundle_path: %s" % bundle_path)
    copy_files_into(policies_path, bundle_path + "plugins")
    copy_files_into(resources_path, bundle_path + "plugins")
    copy_files_into(repositories_path, bundle_path + "plugins", [".*gravitee-repository-elasticsearch.*"])
    copy_files_into(reporters_path, bundle_path + "plugins")
    copy_files_into(services_path, bundle_path + "plugins")
    os.makedirs("%s/ext/repository-jdbc" % bundle_path + "plugins")


def prepare_ui_bundle(ui):
    print("==================================")
    print("Prepare %s" % ui)
    bundle_path = unzip([ui])[0]
    print("        bundle_path: %s" % bundle_path)


def prepare_mgmt_bundle(mgmt):
    print("==================================")
    print("Prepare %s" % mgmt)
    bundle_path = unzip([mgmt])[0]
    print("        bundle_path: %s" % bundle_path)
    copy_files_into(policies_path, bundle_path + "plugins")
    copy_files_into(resources_path, bundle_path + "plugins")
    copy_files_into(fetchers_path, bundle_path + "plugins")
    copy_files_into(repositories_path, bundle_path + "plugins", [".*gravitee-repository-ehcache.*", ".*gravitee-repository-gateway-bridge-http-client.*", ".*gravitee-repository-gateway-bridge-http-server.*"])
    copy_files_into(services_path, bundle_path + "plugins", [".*gravitee-gateway-services-ratelimit.*"])
    os.makedirs("%s/ext/repository-jdbc" % bundle_path + "plugins")

def prepare_policies(version):
    print("==================================")
    print("Prepare Policies")
    dist_dir = get_dist_dir_name()
    policies_dist_path = "%s/%s/gravitee-policies-%s" % (tmp_path, dist_dir, version)
    os.makedirs(policies_dist_path, exist_ok=True)
    copy_files_into(policies_path, policies_dist_path)
    copy_files_into(services_path, policies_dist_path)

def package(version, release_json):
    print("==================================")
    print("Packaging")
    packages = []
    exclude_from_full_zip_list = [re.compile(".*graviteeio-policies.*")]
    dist_dir = get_dist_dir_name()
    full_zip_name = "graviteeio-full-%s" % version

    # how to create a symbolic link ?
    #if jdbc:
    #    full_zip_name = "graviteeio-full-jdbc-%s" % version

    full_zip_path = "%s/%s/%s.zip" % (tmp_path, dist_dir, full_zip_name)
    dirs = [os.path.join("%s/%s/" % (tmp_path, dist_dir), fn) for fn in next(os.walk("%s/%s/" % (tmp_path, dist_dir)))[1]]
    # add release.json
    jsonfile_name = "release.json"
    jsonfile_absname = os.path.join("%s/%s/%s" % (tmp_path, dist_dir, jsonfile_name))
    jsonfile = open(jsonfile_absname, "w")
    jsonfile.write("%s" % json.dumps(release_json, indent=4))
    jsonfile.close()
    with zipfile.ZipFile(full_zip_path, "w", zipfile.ZIP_DEFLATED) as full_zip:
        print("Create %s" % full_zip_path)
        packages.append(full_zip_path)

        full_zip.write(jsonfile_absname, jsonfile_name)
        for d in dirs:
            with zipfile.ZipFile("%s.zip" % d, "w", zipfile.ZIP_DEFLATED) as bundle_zip:
                print("Create %s.zip" % d)
                packages.append("%s.zip" % d)
                dir_abs_path = os.path.abspath(d)
                dir_name = os.path.split(dir_abs_path)[1]
                for dirname, subdirs, files in os.walk(dir_abs_path):
                    exclude_from_full_zip = False
                    for pattern in exclude_from_full_zip_list:
                        if pattern.match(d):
                            exclude_from_full_zip = True
                            break
                    for filename in files:
                        absname = os.path.abspath(os.path.join(dirname, filename))
                        arcname = absname[len(dir_abs_path) - len(dir_name):]
                        bundle_zip.write(absname, arcname)
                        if exclude_from_full_zip is False:
                            full_zip.write(absname, "%s/%s" % (full_zip_name, arcname))
                    if len(files) == 0:
                        absname = os.path.abspath(dirname)
                        arcname = absname[len(dir_abs_path) - len(dir_name):]
                        bundle_zip.write(absname, arcname)
                        if exclude_from_full_zip is False:
                            full_zip.write(absname, "%s/%s" % (full_zip_name, arcname))
    return packages


def rename(string):
    return string.replace("gravitee", "graviteeio") \
        .replace("management-standalone", "management-api") \
        .replace("management-webui", "management-ui") \
        .replace("portal-webui", "portal-ui") \
        .replace("standalone-", "")


def clean_dir_names():
    print("==================================")
    print("Clean directory names")
    dirs = [os.path.join("%s/%s/" % (tmp_path, get_dist_dir_name()), fn) for fn in next(os.walk("%s/%s/" % (tmp_path, get_dist_dir_name())))[1]]
    for d in dirs:
        os.rename(d, rename(d))


def response_pretty_print(r):
    print("###########################################################")
    print("STATUS %s" % r.status_code)
    print("HEADERS \n%s" % r.headers)
    print("RESPONSE \n%s" % r.text)
    print("###########################################################\n\n")
    r.raise_for_status()


def get_dist_dir_name():
    dist_dir = "dist"
    return dist_dir


def main():
    if is_latest_param:
        release_json_url = "https://raw.githubusercontent.com/gravitee-io/release/master/release.json"
    else:
        release_json_url = "https://raw.githubusercontent.com/gravitee-io/release/%s/release.json" % version_param

    print(release_json_url)
    release_json = requests.get(release_json_url)
    print(release_json)
    release_json = release_json.json()
    version = release_json['version']

    print("Create bundles for Gravitee.io v%s" % version)
    clean()

    v3 = int(version[0]) > 1
    if v3:
        portal_ui = download_portal_ui(get_component_by_name(release_json, "gravitee-portal-webui"), version)
        mgmt_api = download_managementV3_api(get_component_by_name(release_json, "gravitee-management-rest-api"), version)
    else:
        mgmt_api = download_management_api(get_component_by_name(release_json, "gravitee-management-rest-api"), version)

    ui = download_ui(get_component_by_name(release_json, "gravitee-management-webui"), version)
    gateway = download_gateway(get_component_by_name(release_json, "gravitee-gateway"), version)
    download_policies(get_policies(release_json))
    download_resources(get_resources(release_json))
    download_fetchers(get_fetchers(release_json))
    download_services(get_services(release_json))
    download_reporters(get_reporters(release_json))
    download_repositories(get_repositories(release_json))

    if v3:
        prepare_ui_bundle(portal_ui)

    prepare_gateway_bundle(gateway)
    prepare_ui_bundle(ui)
    prepare_mgmt_bundle(mgmt_api)
    prepare_policies(version)
    clean_dir_names()
    package(version, release_json)

main()
