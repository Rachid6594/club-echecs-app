from dataclasses import dataclass, field

import chess
import chess.pgn


class IllegalMoveError(ValueError):
    pass


@dataclass(frozen=True)
class MoveResult:
    uci: str
    san: str
    fen_before: str
    fen_after: str
    move_number: int
    side: str
    is_capture: bool
    is_check: bool
    is_checkmate: bool
    is_stalemate: bool
    is_castling: bool
    is_en_passant: bool
    promotion_piece: str | None
    outcome: str | None


@dataclass
class ChessGameState:
    fen: str = chess.STARTING_FEN
    history: list[MoveResult] = field(default_factory=list)

    @classmethod
    def from_fen(cls, fen: str) -> "ChessGameState":
        chess.Board(fen)
        return cls(fen=fen)

    @property
    def board(self) -> chess.Board:
        return chess.Board(self.fen)

    def legal_moves_uci(self) -> list[str]:
        return [move.uci() for move in self.board.legal_moves]

    def play_uci(self, uci: str) -> MoveResult:
        board = self.board
        fen_before = board.fen()

        try:
            move = chess.Move.from_uci(uci)
        except ValueError as exc:
            raise IllegalMoveError("Format de coup UCI invalide.") from exc

        if move not in board.legal_moves:
            raise IllegalMoveError("Coup illegal.")

        side = "white" if board.turn == chess.WHITE else "black"
        move_number = board.fullmove_number
        san = board.san(move)
        is_capture = board.is_capture(move)
        is_castling = board.is_castling(move)
        is_en_passant = board.is_en_passant(move)
        promotion_piece = chess.piece_symbol(move.promotion) if move.promotion else None

        board.push(move)
        outcome_obj = board.outcome(claim_draw=True)
        result = MoveResult(
            uci=move.uci(),
            san=san,
            fen_before=fen_before,
            fen_after=board.fen(),
            move_number=move_number,
            side=side,
            is_capture=is_capture,
            is_check=board.is_check(),
            is_checkmate=board.is_checkmate(),
            is_stalemate=board.is_stalemate(),
            is_castling=is_castling,
            is_en_passant=is_en_passant,
            promotion_piece=promotion_piece,
            outcome=outcome_obj.result() if outcome_obj else None,
        )
        self.fen = board.fen()
        self.history.append(result)
        return result

    def play_san(self, san: str) -> MoveResult:
        board = self.board
        try:
            move = board.parse_san(san)
        except ValueError as exc:
            raise IllegalMoveError("Notation SAN invalide ou coup illegal.") from exc
        return self.play_uci(move.uci())

    def status(self) -> dict:
        board = self.board
        outcome = board.outcome(claim_draw=True)
        return {
            "fen": board.fen(),
            "turn": "white" if board.turn == chess.WHITE else "black",
            "is_check": board.is_check(),
            "is_checkmate": board.is_checkmate(),
            "is_stalemate": board.is_stalemate(),
            "is_insufficient_material": board.is_insufficient_material(),
            "can_claim_draw": board.can_claim_draw(),
            "outcome": outcome.result() if outcome else None,
        }

    def pgn(self) -> str:
        board = chess.Board()
        game = chess.pgn.Game()
        node = game
        for result in self.history:
            move = board.parse_uci(result.uci)
            node = node.add_variation(move)
            board.push(move)
        return str(game)

