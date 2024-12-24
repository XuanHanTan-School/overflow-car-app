enum CommandType {
  ping("ping"),
  drive("drive");

  const CommandType(this.typeStr);

  final String typeStr;
}