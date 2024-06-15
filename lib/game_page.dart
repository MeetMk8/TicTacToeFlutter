import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';

class GamePage extends StatefulWidget {
  final String player1Name;
  final String player2Name;

  GamePage({required this.player1Name, required this.player2Name});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  static const int boardSize = 3;
  late List<List<String>> _board;
  String _currentPlayer = 'X';
  late String _currentPlayerName;
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _board = List.generate(boardSize, (_) => List.generate(boardSize, (_) => ''));
    _currentPlayerName = widget.player1Name;
    _announceTurn();
  }

  void _announceTurn() async {
    await _flutterTts.speak("$_currentPlayerName's turn");
  }

  void _announceWinner(String winner) async {
    await _flutterTts.speak("$winner wins!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tic Tac Toe')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$_currentPlayerName\'s turn',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            SizedBox(height: 20),
            _buildBoard(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetGame,
              child: Text('Reset Game'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoard() {
    return AspectRatio(
      aspectRatio: 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(boardSize, (i) {
          return Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(boardSize, (j) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _handleTap(i, j),
                    child: Container(
                      margin: EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(color: Colors.black),
                      ),
                      child: Center(
                        child: _buildPlayerSymbol(_board[i][j]),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPlayerSymbol(String symbol) {
    if (symbol == 'X') {
      return Image.asset('lib/assets/images/x.jpg'); // Ensure you have the correct path
    } else if (symbol == 'O') {
      return Image.asset('lib/assets/images/o.jpg'); // Ensure you have the correct path
    } else {
      return Container();
    }
  }

  void _handleTap(int i, int j) {
    if (_board[i][j].isEmpty) {
      setState(() {
        _board[i][j] = _currentPlayer;
        if (_checkWinner(_currentPlayer)) {
          _showWinnerDialog(_currentPlayerName);
        } else if (_isBoardFull()) {
          _showWinnerDialog('No one');
        } else {
          _switchPlayer();
          _announceTurn();
        }
      });
    }
  }

  void _switchPlayer() {
    if (_currentPlayer == 'X') {
      _currentPlayer = 'O';
      _currentPlayerName = widget.player2Name;
    } else {
      _currentPlayer = 'X';
      _currentPlayerName = widget.player1Name;
    }
  }

  bool _checkWinner(String player) {
    for (int i = 0; i < boardSize; i++) {
      if (_board[i].every((cell) => cell == player) || _board.every((row) => row[i] == player)) {
        return true;
      }
    }
    if (List.generate(boardSize, (i) => _board[i][i]).every((cell) => cell == player) ||
        List.generate(boardSize, (i) => _board[i][boardSize - 1 - i]).every((cell) => cell == player)) {
      return true;
    }
    return false;
  }

  bool _isBoardFull() {
    return _board.every((row) => row.every((cell) => cell.isNotEmpty));
  }

  void _showWinnerDialog(String winner) {
    _announceWinner(winner);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Lottie.asset('lib/assets/animation/party-popper.json'),
                  Text(
                    '$winner wins!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _resetGame() {
    setState(() {
      _board = List.generate(boardSize, (_) => List.generate(boardSize, (_) => ''));
      _currentPlayer = 'X';
      _currentPlayerName = widget.player1Name;
      _announceTurn();
    });
  }
}
