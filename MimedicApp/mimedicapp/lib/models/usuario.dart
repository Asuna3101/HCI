class Usuario {
  final int idUsuario;
  final String nombre;
  final DateTime fechaNacimiento;
  final String celular;
  final String correo;
  final String contrasena;
  final String? foto; // base64
  final String? fotoContentType;

  Usuario({
    required this.idUsuario,
    required this.nombre,
    required this.fechaNacimiento,
    required this.celular,
    required this.correo,
    required this.contrasena,
    this.foto,
    this.fotoContentType,
  });

  // Constructor para crear usuario para registro (sin ID)
  Usuario.forRegistration({
    required this.nombre,
    required this.fechaNacimiento,
    required this.celular,
    required this.correo,
    required this.contrasena,
    this.foto,
    this.fotoContentType,
  }) : idUsuario = 0; // ID temporal para registro

// Método toString para representar la clase como un String
  @override
  String toString() {
    return 'Usuario{idUsuario: $idUsuario, nombre: $nombre, fechaNacimiento: $fechaNacimiento, celular: $celular, correo: $correo}';
  }

// Método para convertir la instancia a un Map (JSON) - Compatible con backend
  Map<String, dynamic> toJson() {
    return {
      'id': idUsuario,
      'nombre': nombre,
      'fecha_nacimiento':
          fechaNacimiento.toIso8601String().split('T')[0], // Solo fecha
      'celular': celular,
      'correo': correo,
      'password': contrasena,
    };
  }

  // Método para convertir a JSON para registro
  Map<String, dynamic> toRegistrationJson() {
    return {
      'nombre': nombre,
      'fecha_nacimiento':
          fechaNacimiento.toIso8601String().split('T')[0], // Solo fecha
      'celular': celular,
      'correo': correo,
      'password': contrasena,
    };
  }

// Método para crear una instancia de Usuario a partir de un Map (compatible con backend)
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      idUsuario: json['id'] ?? json['idUsuario'] ?? 0,
      nombre: json['nombre'] ?? '',
      fechaNacimiento: json['fecha_nacimiento'] != null
          ? DateTime.parse(json['fecha_nacimiento'])
          : json['fechaNacimiento'] != null
              ? DateTime.parse(json['fechaNacimiento'])
          : DateTime.now(),
      celular: json['celular'] ?? '',
      correo: json['correo'] ?? '',
      contrasena: json['password'] ?? json['contrasena'] ?? '',
      foto: json['photo'] as String?,
      fotoContentType: json['photo_content_type'] as String?,
    );
  }

  // Método para crear copia con modificaciones
  Usuario copyWith({
    int? idUsuario,
    String? nombre,
    DateTime? fechaNacimiento,
    String? celular,
    String? correo,
    String? contrasena,
    String? foto,
    String? fotoContentType,
  }) {
    return Usuario(
      idUsuario: idUsuario ?? this.idUsuario,
      nombre: nombre ?? this.nombre,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      celular: celular ?? this.celular,
      correo: correo ?? this.correo,
      contrasena: contrasena ?? this.contrasena,
      foto: foto ?? this.foto,
      fotoContentType: fotoContentType ?? this.fotoContentType,
    );
  }
}
