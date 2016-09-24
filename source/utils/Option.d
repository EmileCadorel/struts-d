module utils.Option;

import utils.Singleton;

class Option {

  this () {}
  this (string[string] list) {
    foreach (key, value ; list) {
      if (key == "LOG_FILE_PATH") {
	this._log_file_path = list[key];
      } else if (key == "CONF_FILE_PATH") {
	this._config_file_path = list[key];
      }
    }
  }

  ref string log_file_path() {
    return this._log_file_path;
  }

  ref string config_file_path() {
    return this._config_file_path;
  }

  mixin Singleton!Option;

  private {
    string _log_file_path;
    string _config_file_path;
  }
}