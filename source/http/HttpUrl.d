module http.HttpUrl;
import std.container, std.outbuffer, std.conv;

class HttpUrl {

  enum ParamEnum {
    STRING,
      INT,
      FLOAT,
      VOID
      }

  struct Parameter {
    ParamEnum type;
    void [] data;

    ref T to (T) () {
      return (cast(T[])this.data)[0];
    }

    static ref Parameter empty () {
      return _empty;
    }

    private {
      static Parameter _empty = Parameter (ParamEnum.VOID, null);
    }

    string toString () {
      switch (type) {
      case ParamEnum.STRING: return "Parameter(STRING," ~ cast(string)data ~ ")";
      case ParamEnum.INT: return "Parameter(INT," ~ std.conv.to!string ((cast(int[])data)[0]) ~ ")";
      case ParamEnum.FLOAT: return "Parameter(FLOAT," ~ std.conv.to!string ((cast(float[])data)[0]) ~ ")";
      default : return "Parameter (VOID)";
      }
    }

  }

  this (Array!string path) {
    this._path = path;
  }

  this (Array!string path, Parameter[string] params) {
    this._path = path;
    this._params = params;
  }

  ref Array!string path () {
    return this._path;
  }

  ref Parameter param (string name) {
    auto it = (name in _params);
    if (it !is null) return *it;
    else return Parameter.empty;
  }

  ref Parameter [string] params () {
    return this._params;
  }

  string toString () {
    OutBuffer buf = new OutBuffer;
    buf.write ("PATH : /");
    foreach (it ; path) {
      buf.write (it);
      buf.write (" / ");
    }
    buf.write ("?" ~ to!string (_params));
    return buf.toString ();
  }

  private {
    Array!string _path;
    Parameter [string] _params;
  }
}
