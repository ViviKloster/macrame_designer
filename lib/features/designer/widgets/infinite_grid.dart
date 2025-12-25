import 'package:flutter/material.dart';
import 'package:macrame_designer/features/designer/models/grid_model.dart';

class InfiniteGrid extends StatefulWidget {
  final List<PlacedKnot> placedKnots;
  final Function(GridCell, KnotType) onKnotPlaced;
  final double cellSize;

  const InfiniteGrid({
    super.key,
    required this.placedKnots,
    required this.onKnotPlaced,
    this.cellSize = 60.0,
  });

  @override
  State<InfiniteGrid> createState() => _InfiniteGridState();
}

class _InfiniteGridState extends State<InfiniteGrid> {
  double _offsetX = 0.0;
  double _offsetY = 0.0;
  double _scale = 1.0;
  
  KnotType? _draggingKnot;
  Offset? _dragPosition;
  GridCell? _hoveredCell;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      onScaleEnd: _onScaleEnd,
      child: Stack(
        children: [
          // Cuadrícula de fondo
          CustomPaint(
            painter: _GridPainter(
              offsetX: _offsetX,
              offsetY: _offsetY,
              scale: _scale,
              cellSize: widget.cellSize,
              placedKnots: widget.placedKnots,
              hoveredCell: _hoveredCell,
            ),
          ),
          
          // Área para soltar nudos (VERSIÓN SIMPLIFICADA)
          Positioned.fill(
            child: DragTarget<KnotType>(
              onWillAcceptWithDetails: (details) {
                setState(() {
                  _draggingKnot = details.data;
                });
                return true;
              },
              onAcceptWithDetails: (details) {
                if (_hoveredCell != null) {
                  widget.onKnotPlaced(_hoveredCell!, details.data);
                }
                setState(() {
                  _draggingKnot = null;
                  _dragPosition = null;
                  _hoveredCell = null;
                });
              },
              // ELIMINAMOS 'onMove' completamente - lo simulamos con MouseRegion
              onLeave: (leftData) {
                setState(() {
                  _draggingKnot = null;
                  _hoveredCell = null;
                  _dragPosition = null;
                });
              },
              builder: (context, candidateData, rejectedData) {
                return MouseRegion(
                  onHover: (event) {
                    if (_draggingKnot != null) {
                      final cell = _findCellAtPosition(event.localPosition);
                      if (cell != _hoveredCell) {
                        setState(() {
                          _hoveredCell = cell;
                        });
                      }
                    }
                  },
                  child: Container(color: Colors.transparent),
                );
              },
            ),
          ),
          
          // Nudo siendo arrastrado
          if (_draggingKnot != null && _dragPosition != null)
            Positioned(
              left: _dragPosition!.dx - 25,
              top: _dragPosition!.dy - 25,
              child: Opacity(
                opacity: 0.8,
                child: _buildKnotWidget(_draggingKnot!),
              ),
            ),
        ],
      ),
    );
  }

  void _onScaleStart(ScaleStartDetails details) {
    if (_draggingKnot != null) return;
    
    final localPosition = details.localFocalPoint;
    final knot = _findKnotAtPosition(localPosition);
    if (knot != null) {
      setState(() {
        _draggingKnot = knot.type;
        _dragPosition = localPosition;
      });
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_draggingKnot != null) {
      setState(() {
        _dragPosition = details.localFocalPoint;
      });
    } else {
      setState(() {
        _offsetX += details.focalPointDelta.dx;
        _offsetY += details.focalPointDelta.dy;
        _scale *= details.scale;
      });
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (_draggingKnot != null && _hoveredCell != null) {
      widget.onKnotPlaced(_hoveredCell!, _draggingKnot!);
    }
    
    setState(() {
      _draggingKnot = null;
      _dragPosition = null;
      _hoveredCell = null;
    });
  }

  GridCell? _findCellAtPosition(Offset position) {
    final transformedX = (position.dx - _offsetX) / _scale;
    final transformedY = (position.dy - _offsetY) / _scale;
    final transformedPos = Offset(transformedX, transformedY);

    const searchRadius = 2;
    final approxRow = (transformedPos.dy / widget.cellSize).round();
    final approxCol = (transformedPos.dx / widget.cellSize).round();

    for (int c = approxCol - searchRadius; c <= approxCol + searchRadius; c++) {
      for (int r = approxRow - searchRadius; r <= approxRow + searchRadius; r++) {
        final isOffsetRow = r.isOdd;
        final cell = GridCell(r, c, isOffsetRow: isOffsetRow);
        
        final cellCenter = _calculateCellCenter(cell, widget.cellSize);
        final halfSize = widget.cellSize / 2;
        final contains = transformedPos.dx >= cellCenter.dx - halfSize &&
                         transformedPos.dx <= cellCenter.dx + halfSize &&
                         transformedPos.dy >= cellCenter.dy - halfSize &&
                         transformedPos.dy <= cellCenter.dy + halfSize;
        
        if (contains) {
          return cell;
        }
      }
    }
    return null;
  }

  PlacedKnot? _findKnotAtPosition(Offset position) {
    for (final knot in widget.placedKnots) {
      final cellCenter = _calculateCellCenter(knot.cell, widget.cellSize);
      final transformedCenter = Offset(
        cellCenter.dx * _scale + _offsetX,
        cellCenter.dy * _scale + _offsetY,
      );
      
      final distance = (position - transformedCenter).distance;
      if (distance < widget.cellSize * _scale / 2) {
        return knot;
      }
    }
    return null;
  }

  Widget _buildKnotWidget(KnotType knotType) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: knotType.color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        knotType.icon,
        color: Colors.white,
        size: 30,
      ),
    );
  }

  Offset _calculateCellCenter(GridCell cell, double cellSize) {
    final baseX = cell.col * cellSize;
    final baseY = cell.row * cellSize;
    final offsetX = cell.isOffsetRow ? cellSize / 2 : 0;
    return Offset(baseX + offsetX, baseY);
  }
}

class _GridPainter extends CustomPainter {
  final double offsetX;
  final double offsetY;
  final double scale;
  final double cellSize;
  final List<PlacedKnot> placedKnots;
  final GridCell? hoveredCell;

  _GridPainter({
    required this.offsetX,
    required this.offsetY,
    required this.scale,
    required this.cellSize,
    required this.placedKnots,
    this.hoveredCell,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.brown.withOpacity(0.3)
      ..strokeWidth = 1.0 / scale
      ..style = PaintingStyle.stroke;

    final offsetColumnPaint = Paint()
      ..color = Colors.brown.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final normalColumnPaint = Paint()
      ..color = Colors.brown.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    final visibleRect = Rect.fromLTWH(
      -offsetX / scale,
      -offsetY / scale,
      size.width / scale,
      size.height / scale,
    );

    final startRow = (visibleRect.top / cellSize).floor() - 2;
    final endRow = (visibleRect.bottom / cellSize).ceil() + 2;
    final startCol = (visibleRect.left / cellSize).floor() - 2;
    final endCol = (visibleRect.right / cellSize).ceil() + 2;

    for (int row = startRow; row <= endRow; row++) {
      for (int col = startCol; col <= endCol; col++) {
        final isOffsetRow = row.isOdd;
        final cell = GridCell(row, col, isOffsetRow: isOffsetRow);
        
        final cellCenter = _calculateCellCenter(cell, cellSize);
        final screenX = cellCenter.dx * scale + offsetX;
        final screenY = cellCenter.dy * scale + offsetY;
        final screenSize = cellSize * scale;
        
        final cellRect = Rect.fromCenter(
          center: Offset(screenX, screenY),
          width: screenSize,
          height: screenSize,
        );
        
        canvas.drawRect(
          cellRect,
          isOffsetRow ? offsetColumnPaint : normalColumnPaint,
        );
        canvas.drawRect(cellRect, gridPaint);
        
        if (hoveredCell?.row == row && hoveredCell?.col == col) {
          canvas.drawRect(
            cellRect,
            Paint()
              ..color = Colors.blue.withOpacity(0.2)
              ..style = PaintingStyle.fill,
          );
        }
        
        for (final knot in placedKnots) {
          if (knot.cell.row == row && knot.cell.col == col) {
            _drawKnot(canvas, Offset(screenX, screenY), screenSize, knot);
          }
        }
      }
    }
  }

  void _drawKnot(Canvas canvas, Offset center, double size, PlacedKnot knot) {
    final knotPaint = Paint()
      ..color = knot.type.color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, size * 0.4, knotPaint);
    canvas.drawCircle(center, size * 0.4, borderPaint);
  }

  Offset _calculateCellCenter(GridCell cell, double cellSize) {
    final baseX = cell.col * cellSize;
    final baseY = cell.row * cellSize;
    final offsetX = cell.isOffsetRow ? cellSize / 2 : 0;
    return Offset(baseX + offsetX, baseY);
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return offsetX != oldDelegate.offsetX ||
        offsetY != oldDelegate.offsetY ||
        scale != oldDelegate.scale ||
        !_listEquals(placedKnots, oldDelegate.placedKnots) ||
        hoveredCell != oldDelegate.hoveredCell;
  }
  
  bool _listEquals(List<PlacedKnot> a, List<PlacedKnot> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }
}