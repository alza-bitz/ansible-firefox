ansible-firefox
===============

A role for configuring Firefox, including addons, preferences and css styles.

Notes:

  - A Firefox profile named 'default' will be created if it doesn't already exist.
  - If any addon being installed is a 'complete theme' addon, it will be set as the selected theme (this is the default behaviour of the `firefox-addon` role dependency).

Requirements
------------

Currently the role has only been tested against Fedora (23) hosts, but in theory should work for all Linux variants. 

Role Variables
--------------

### For Installing Addons
```
firefox:
  addons:
    - url: <url-of-addon-page-on-addons.mozilla.org> e.g. https://addons.mozilla.org/en-US/firefox/addon/adwaita
      prefs:
        - name: <name-of-pref-in-prefs.js> e.g. extensions.gnome-theme-tweak.relief-buttons
          value: <value-of-pref>
```
### For Installing Preferences
```
firefox:
  prefs:
    - name: <name-of-pref-in-prefs.js>
      value: <value-of-pref>
```
### For Installing User Styles
```
firefox:
  styles:
    - <url-of-style-page-on-userstyles.org> e.g. https://userstyles.org/styles/96733/headerbar-style-for-gnome-3-16
```
### For Customising the UI
```
firefox:
  ui_customisation:
    add:
      - placement: <placement-to-add-item-to>
        item: <item-to-add>
    remove:
      - placement: <placement-to-remove-item-from>
        item: <item-to-remove>
```

Dependencies
------------

This role depends on the following other roles from Ansible Galaxy:

- https://galaxy.ansible.com/alzadude/firefox-addon

Installation
------------

Install from Ansible Galaxy by executing the following command:

```
ansible-galaxy install alzadude.firefox
```

Example Playbook
----------------

The following playbook gives an example of usage. This particular example is inspired by https://github.com/chpii/Headerbar, which aims to automate the configuration required to give Firefox a 'native' GNOME look and feel on Linux.

Save the following configuration into files with the specified names:

**playbook.yml:**
```
---

- hosts: linux-workstation
  sudo: no

  vars:
    firefox:
      addons:
        - url: https://addons.mozilla.org/en-US/firefox/addon/adwaita
        - url: https://addons.mozilla.org/en-US/firefox/addon/gnome-theme-tweak
          prefs: 
            - name: extensions.gnome-theme-tweak.relief-buttons
              value: true
            - name: extensions.gnome-theme-tweak.tab-max-width
              value: 4
        - url: https://addons.mozilla.org/en-US/firefox/addon/hide-tab-bar-with-one-tab
      prefs:
        - name: browser.tabs.animate
          value: false
      styles:
        - https://userstyles.org/styles/96733/headerbar-style-for-gnome-3-16
        - https://userstyles.org/styles/115022/gnome-styled-menu-list-view
      ui_customisation:
        add:
          - placement: nav-bar
            item: new-tab-button
        remove:
          - placement: TabsToolbar
            item: new-tab-button

  roles:
    - alzadude.firefox
```

**hosts:**

```
# Dummy inventory for ansible
linux-workstation ansible_host=localhost ansible_connection=local
```
Then run the playbook with the following command:
```
ansible-playbook -i hosts playbook.yml
```

License
-------

BSD

