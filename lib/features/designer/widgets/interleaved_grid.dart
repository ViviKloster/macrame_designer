import 'package:flutter/material.dart';
import 'package:macrame_designer/features/designer/models/grid_model.dart';

class InterleavedGrid extends StatefulWidget {
  final double cellSize;
  final List<PlacedKnot> placedKnots;
  final void Function(GridCell, KnotType, PlacedKnot?)? onKnotPlaced;
  final KnotType? selectedKnotType;
  final int rows;
  final int columns;

  const InterleavedGrid({
    Key? key,
    this.cellSize = 60.0,
    required this.placedKnots,
    this.onKnotPlaced,
    this.selectedKnotType,
    this.rows = 20,
    this.columns = 20,
  }) : super(key: key);

  @override
  State<InterleavedGrid> createState() => _InterleavedGridState();
}

class _InterleavedGridState extends State<InterleavedGrid> {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();
  final GlobalKey _gridKey = GlobalKey();
  KnotType? _draggedKnotType;
  GridCell? _hoveredCell;
  PlacedKnot? _knotToReplace;

  @override
  Widget build(BuildContext context) {
    return DragTarget<KnotType>(
      // CORRECCIÓN: 'knotType' es un DragTargetDetails. Accedemos a su propiedad 'data'
      onAcceptWithDetails: (DragTargetDetails<KnotType> details) {
        if (_hoveredCell != null && widget.onKnotPlaced != null) {
          // Usamos 'details.data' que es del tipo KnotType
          widget.onKnotPlaced!(_hoveredCell!, details.data, _knotToReplace);
        }
        setState(() {
          _draggedKnotType = null;
          _hoveredCell = null;
          _knotToReplace = null;
        });
      },
      onWillAcceptWithDetails: (DragTargetDetails<KnotType> details) {
        // CORRECCIÓN: Asignamos 'details.data', no el objeto details completo
        setState(() {
          _draggedKnotType = details.data;
        });
        return true;
      },
      onLeave: (KnotType? leftData) {
        setState(() {
          _draggedKnotType = null;
          _hoveredCell = null;
          _knotToReplace = null;
        });
      },
      builder: (context, candidateData, rejectedData) {
        return Scrollbar(
          controller: _horizontalController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _horizontalController,
            scrollDirection: Axis.horizontal,
            child: Scrollbar(
              controller: _verticalController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _verticalController,
                child: Container(
                  key: _gridKey,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: List.generate(widget.rows, (row) {
                      // Filas impares (1, 3, 5...) se desplazan exactamente media celda
                      final bool shouldOffsetRow = row.isOdd; // 1, 3, 5...
                      
                      return Container(
                        // Desplazamiento EXACTO de media celda
                        // Usamos Transform.translate para precisión
                        child: Transform.translate(
                          offset: Offset(
                            shouldOffsetRow ? widget.cellSize / 2 : 0,
                            0,
                          ),
                          child: Row(
                            // Para compensar el desplazamiento, reducimos una columna
                            // en las filas desplazadas para que quede simétrico
                            children: List.generate(
                              shouldOffsetRow ? widget.columns : widget.columns,
                              (col) {
                                final cell = GridCell(row, col, isOffsetRow: shouldOffsetRow);
                                
                                // Buscar si hay un nudo en esta celda
                                PlacedKnot? knot;
                                try {
                                  knot = widget.placedKnots.firstWhere(
                                    (k) => k.cell.row == row && k.cell.col == col,
                                  );
                                } catch (e) {
                                  knot = null;
                                }
                                
                                final isHovered = _hoveredCell != null && 
                                    _hoveredCell!.row == row && 
                                    _hoveredCell!.col == col;
                                
                                // Verificar si hay un nudo para reemplazar
                                final bool willReplace = isHovered && knot != null;
                                
                                return MouseRegion(
                                  onEnter: (_) {
                                    if (_draggedKnotType != null) {
                                      setState(() {
                                        _hoveredCell = cell;
                                        _knotToReplace = knot;
                                      });
                                    }
                                  },
                                  onExit: (_) {
                                    if (_hoveredCell == cell) {
                                      setState(() {
                                        _hoveredCell = null;
                                        _knotToReplace = null;
                                      });
                                    }
                                  },
                                  child: _GridCellWidget(
                                    cell: cell,
                                    cellSize: widget.cellSize,
                                    knot: knot,
                                    isHovered: isHovered,
                                    willReplace: willReplace,
                                    hasDraggedKnot: _draggedKnotType != null,
                                    onTap: () {
                                      // Opcional: también permitir clic si hay un nudo seleccionado
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GridCellWidget extends StatelessWidget {
  final GridCell cell;
  final double cellSize;
  final PlacedKnot? knot;
  final bool isHovered;
  final bool willReplace;
  final bool hasDraggedKnot;
  final VoidCallback onTap;

  const _GridCellWidget({
    required this.cell,
    required this.cellSize,
    this.knot,
    this.isHovered = false,
    this.willReplace = false,
    this.hasDraggedKnot = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.grey.withOpacity(0.3);
    double borderWidth = 1.0;
    
    if (willReplace) {
      borderColor = Colors.red.withOpacity(0.7);
      borderWidth = 2.0;
    } else if (isHovered && hasDraggedKnot) {
      borderColor = Colors.blue.withOpacity(0.7);
      borderWidth = 2.0;
    }
    
    return Container(
      width: cellSize,
      height: cellSize,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      child: Stack(
        children: [
          // Nudo (si existe)
          if (knot != null) _buildKnotWidget(knot!),
          
          // Indicador de reemplazo
          if (willReplace)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  border: Border.all(
                    color: Colors.red,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.close,
                    color: Colors.red,
                    size: cellSize * 0.4,
                  ),
                ),
              ),
            ),
          
          // Indicador de hover (cuando hay algo arrastrando)
          if (isHovered && hasDraggedKnot && knot == null && !willReplace)
            Positioned.fill(
              child: Container(
                color: Colors.blue.withOpacity(0.1),
                child: Center(
                  child: Icon(
                    Icons.add_circle_outline,
                    color: Colors.blue.withOpacity(0.5),
                    size: cellSize * 0.3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKnotWidget(PlacedKnot knot) {
    return Center(
      child: Container(
        width: cellSize * 0.6,
        height: cellSize * 0.6,
        decoration: BoxDecoration(
          color: knot.type.color.withOpacity(0.9),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.black,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          knot.type.icon,
          color: Colors.white,
          size: cellSize * 0.35,
        ),
      ),
    );
  }
}