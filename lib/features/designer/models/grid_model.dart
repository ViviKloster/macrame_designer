import 'package:flutter/material.dart';

@immutable
class GridCell {
  final int row;
  final int col;
  final bool isOffsetRow;

  const GridCell(this.row, this.col, {this.isOffsetRow = false});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridCell &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col &&
          isOffsetRow == other.isOffsetRow;

  @override
  int get hashCode => Object.hash(row, col, isOffsetRow);

  @override
  String toString() => 'Cell(r:$row, c:$col, offsetRow:$isOffsetRow)';
}

class KnotType {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final double lengthMultiplier;
  final String description;

  const KnotType({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.lengthMultiplier,
    required this.description,
  });
}

class PlacedKnot {
  final String id;
  final KnotType type;
  final GridCell cell;
  final DateTime placedAt;

  PlacedKnot({
    required this.id,
    required this.type,
    required this.cell,
    required this.placedAt,
  });
}