class Sementes {
  int _id;
  String _produtor;
  String _cultivar;
  String _lote;
  String _peneira;
  String _classe;
  String _kg_bag;
  String _producao_bag;
  String _armazem;
  String _etiqueta_a;
  String _etiqueta_b;
  String _etiqueta_c;
  String _etiqueta_d;
  int _status;
  String _observacoes;
  String _data;
  String _arquivo;

  Sementes(
      this._id,
      this._produtor,
      this._cultivar,
      this._lote,
      this._peneira,
      this._classe,
      this._kg_bag,
      this._producao_bag,
      this._armazem,
      this._etiqueta_a,
      this._etiqueta_b,
      this._etiqueta_c,
      this._etiqueta_d,
      this._status,
      this._observacoes,
      this._data,
      this._arquivo);

  Map toJson(){
    return {
      "id": this._id,
      "produtor": this._produtor,
      "cultivar": this._cultivar,
      "lote": this._lote,
      "peneira": this._peneira,
      "classe": this._classe,
      "kg_bag": this._kg_bag,
      "producao_bag": this._producao_bag,
      "armazem": this._armazem,
      "etiqueta_a": this._etiqueta_a,
      "etiqueta_b": this._etiqueta_b,
      "etiqueta_c": this._etiqueta_c,
      "etiqueta_d": this._etiqueta_d,
      "status": this._status,
      "observacoes": this._observacoes,
      "data": this._data,
      "arquivo": this._arquivo
    };
  }

  String get arquivo => _arquivo;

  set arquivo(String value) {
    _arquivo = value;
  }

  String get data => _data;

  set data(String value) {
    _data = value;
  }

  String get observacoes => _observacoes;

  set observacoes(String value) {
    _observacoes = value;
  }

  int get status => _status;

  set status(int value) {
    _status = value;
  }

  String get etiqueta_d => _etiqueta_d;

  set etiqueta_d(String value) {
    _etiqueta_d = value;
  }

  String get etiqueta_c => _etiqueta_c;

  set etiqueta_c(String value) {
    _etiqueta_c = value;
  }

  String get etiqueta_b => _etiqueta_b;

  set etiqueta_b(String value) {
    _etiqueta_b = value;
  }

  String get etiqueta_a => _etiqueta_a;

  set etiqueta_a(String value) {
    _etiqueta_a = value;
  }

  String get armazem => _armazem;

  set armazem(String value) {
    _armazem = value;
  }

  String get producao_bag => _producao_bag;

  set producao_bag(String value) {
    _producao_bag = value;
  }

  String get kg_bag => _kg_bag;

  set kg_bag(String value) {
    _kg_bag = value;
  }

  String get classe => _classe;

  set classe(String value) {
    _classe = value;
  }

  String get peneira => _peneira;

  set peneira(String value) {
    _peneira = value;
  }

  String get lote => _lote;

  set lote(String value) {
    _lote = value;
  }

  String get cultivar => _cultivar;

  set cultivar(String value) {
    _cultivar = value;
  }

  String get produtor => _produtor;

  set produtor(String value) {
    _produtor = value;
  }

  int get id => _id;

  set id(int value) {
    _id = value;
  }
}
