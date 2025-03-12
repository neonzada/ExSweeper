defmodule Minesweeper do
  @moduledoc "A module that implements functions for the game Minesweeper."

  def get_arr([h|_t], 0), do: h
  @doc "Recebe uma lista e uma posição e devolve o elemento na posição n do vetor. O vetor começa na posição 0 (zero)."
  def get_arr([_h|t], n), do: get_arr(t, n-1)

  def update_arr([_h|t],0,v), do: [v|t]
  @doc "Recebe uma lista, uma posição e um novo valor e devolve um novo vetor com o valor v na posição n. O vetor começa na posição 0 (zero)."
  def update_arr([h|t],n,v), do: [h|update_arr(t, n-1, v)]

  @doc "Recebe um tabuleiro (matriz), uma linha e uma coluna. Devolve o elemento na posição tabuleiro[l,c]."
  def get_pos(tab,l,c), do: get_arr(get_arr(tab, l), c)

  @doc "Recebe um tabuleiro, uma linha, uma coluna e um novo valor. Devolve o tabuleiro modificado com o novo valor na posição linha x coluna."
  def update_pos(tab,l,c,v), do: update_arr(tab, l, update_arr(get_arr(tab, l), c, v))

  @doc "Recebe um tabuleiro com o mapeamento das minas, uma linha, uma coluna. Devolve true caso a posição contenha uma mina e false caso contrário."
  def is_mine(minas,l,c), do: get_pos(minas, l, c)

  @doc "Recebe o tamanho do tabuleiro, uma linha e uma coluna, e diz se essa posição é válida no tabuleiro."
  def is_valid_pos(size,l,c), do: l < size && c < size && l >= 0 && c >= 0

  @doc "Dado o tamanho do tabuleiro e uma posição atual, retorna uma lista com todas as posições adjacentes à posição atual."
  def valid_moves(tam,l,c) do
    directions = [
      {-1, -1}, {-1, 0},  {-1, 1},
      {0, -1} ,           {0, 1} ,
      {1, -1} ,  {1, 0},  {1, 1}
    ]

    directions
    |> Enum.map(fn {dl, dc} -> {l + dl, c + dc} end)
    |> Enum.filter(fn {l, c} -> is_valid_pos(tam, l, c) end)
  end

  @doc "Recebe um tabuleiro com o mapeamento das minas e uma posição, e conta quantas minas existem nas posições adjacentes."
  def conta_minas_adj(minas,l,c) do
    valid_moves(Enum.count(minas),l,c)
    |> Enum.filter(fn {l, c} -> is_mine(minas,l,c) end)
    |> Enum.count()
  end

  @doc "Recebe uma posição a ser aberta, o mapa de minas e o tabuleiro do jogo. Devolve como resposta o tabuleiro do jogo modificado com essa jogada."
  # Essa função é recursiva, pois no caso da entrada ser uma posição sem minas adjacentes, o algoritmo deve
  # seguir abrindo todas as posições adjacentes até que se encontre posições adjacentes à minas.
  #
  # - Se a posição a ser aberta é uma mina, o tabuleiro não é modificado e encerra;
  # - Se a posição a ser aberta já foi aberta, o tabuleiro não é modificado e encerra;
  # - Se a posição a ser aberta é adjacente a uma ou mais minas, devolver o tabuleiro modificado com o número de minas adjacentes na posição aberta;
  # - Se a posição a ser aberta não possui minas adjacentes, abrimos ela com zero (0) e recursivamente abrimos as outras posições adjacentes a ela.
  def abre_jogada(l, c, minas, tab) do
    adjMines = conta_minas_adj(minas,l,c)
    cond do
      is_mine(minas,l,c) -> tab                         #mine
      get_pos(tab,l,c) != "-" -> tab                    #already open, return tab
      adjMines > 0 -> update_pos(tab,l,c,adjMines)      #adjMines, return tab with num
      true ->                                           #open with 0 and recursively open other adjacent positions
        newTab = update_pos(tab, l, c, 0)
        moves = valid_moves(Enum.count(tab), l, c)
        Enum.reduce(moves, newTab, fn {row, col}, accTab -> abre_jogada(row, col, minas, accTab) end)
    end
  end

  @doc """
  Recebe um tabueiro de jogos, o mapa de minas, uma linha e uma coluna e verifica:
  - Se a posição {l,c} já está aberta (contém um número), a posição não é modificada;
  - Se a posição {l,c} contém uma mina no mapa de minas, marca com "*" no tabuleiro;
  - Se a posição {l,c} está fechada (contém "-"), escreve o número de minas adjacentes nesta posição no tabuleiro.
  """
  def abre_posicao(tab,minas,l,c) do
    cond do
      is_mine(minas, l, c) -> update_pos(tab, l, c, "*")
      get_pos(tab, l, c) == "-" -> update_pos(tab, l, c, conta_minas_adj(minas, l, c))
      true -> tab
    end
  end


  @doc "Recebe o mapa de Minas e o tabuleiro do jogo, e abre todo o tabuleiro do jogo, mostrando onde estão as minas e os números nas posições adjecentes às minas."
  #Essa função é usada para mostrar todo o tabuleiro no caso de vitória ou derrota.
  def abre_tabuleiro(minas,tab) do
    range = 0..(Enum.count(tab) - 1)
    moves = for x <- range, y <- range, do: {x, y}

    Enum.reduce(moves, tab, fn {row, col}, accTab -> abre_posicao(accTab, minas, row, col) end)
  end

  @doc """
  Recebe o tabuleiro do jogo e devolve uma string que é a representação visual desse tabuleiro.

  Essa função é aplicada no tabuleiro antes de fazer o print dele na tela.
  """
  def board_to_string(tab) do
    header = print_header(length(hd(tab)))
    rows = print_rows(tab)
    header <> rows
  end

  # was gonna print ?A..(?A + size - 1) but nah too much hassle, still gonna keep it separate for future customization ig
  defp print_header(size) do
    letters = Enum.map(?0..(?0 + size - 1), &<<&1>>)
    "   " <> Enum.join(letters, "   ") <> " \n"
  end

  defp print_rows(tab) do
    tab
    |> Enum.with_index(0)
    |> Enum.map(&print_row/1)
    |> Enum.join("   " <> String.duplicate("-", length(hd(tab)) * 4 - 1) <> " \n")
  end

  defp print_row({row, index}) do
    row_string = row |> Enum.join(" | ")
    "#{index}  " <> row_string <> " \n"
  end

  @doc "Recebe um inteiro n, um valor v, e gera uma lista contendo n vezes o valor v."
  def gera_lista(0,_v), do: []
  def gera_lista(n,v), do: [v|gera_lista(n-1, v)]

  @doc "Recebe o tamanho do tabuleiro e gera um tabuleiro novo, todo fechado."
  def gera_tabuleiro(n), do: gera_lista(n, gera_lista(n, "-"))

  @doc "Recebe o tamanho do tabuleiro e gera um mapa de minas zero, onde todas as posições contém false."
  def gera_mapa_de_minas(n), do: gera_lista(n, gera_lista(n, false))

  @doc "Recebe um tabuleiro de jogo e conta quantas posições fechadas existem no tabuleiro."
  def conta_fechadas(tab) do
    tab
    |> Enum.flat_map(& &1)
    |> Enum.count(&(&1 == "-"))
  end

  @doc "Recebe o tabuleiro de minas e conta quantas minas existem no jogo."
  def conta_minas(minas) do
    minas
    |> Enum.flat_map(& &1)
    |> Enum.count(&(&1 == true))
  end

  @doc """
  Recebe o tabuleiro de minas, o tabuleiro do jogo, e diz se o jogo acabou.

  O jogo acaba quando o número de casas fechadas é igual ao número de minas.
  """
  def end_game(minas,tab), do: conta_fechadas(tab) == conta_minas(minas)

end


defmodule Engine do
  @moduledoc "Engine that handles minesweeper logic."

  def main() do
    v = IO.gets("Digite o tamanho do tabuleiro: \n")
    {size,_} = Integer.parse(v)
    minas = gen_mines_board(size)
    #IO.puts("oi")
    IO.inspect minas
    tabuleiro = Minesweeper.gera_tabuleiro(size)
    game_loop(minas,tabuleiro)
  end

  @doc "Main game loop that checks win/lose conditions for every move that the user inputs."
  def game_loop(minas,tabuleiro) do
    IO.puts Minesweeper.board_to_string(tabuleiro)
    v = IO.gets("Digite uma linha: \n")
    {linha,_} = Integer.parse(v)
    v = IO.gets("Digite uma coluna: \n")
    {coluna,_} = Integer.parse(v)
    if (Minesweeper.is_mine(minas,linha,coluna)) do
      IO.puts "VOCÊ PERDEU!!!!!!!!!!!!!!!!"
      IO.puts Minesweeper.board_to_string(Minesweeper.abre_tabuleiro(minas,tabuleiro))
      IO.puts "TENTE NOVAMENTE!!!!!!!!!!!!"
    else
      novo_tabuleiro = Minesweeper.abre_jogada(linha,coluna,minas,tabuleiro)
      if (Minesweeper.end_game(minas,novo_tabuleiro)) do
        IO.puts "VOCÊ VENCEU!!!!!!!!!!!!!!"
        IO.puts Minesweeper.board_to_string(Minesweeper.abre_tabuleiro(minas,novo_tabuleiro))
        IO.puts "PARABÉNS!!!!!!!!!!!!!!!!!"
      else
        game_loop(minas,novo_tabuleiro)
      end
    end
  end

  @doc "Generates a board of mines based on the random values generated by add_mines/3"
  def gen_mines_board(size) do
    add_mines(ceil(size*size*0.15), size, Minesweeper.gera_mapa_de_minas(size))
  end

  def add_mines(0,_size,mines), do: mines
  @doc "Generates random positions and places n mines on them."
  def add_mines(n,size,mines) do
    linha = :rand.uniform(size-1)
    coluna = :rand.uniform(size-1)
    if Minesweeper.is_mine(mines,linha,coluna) do
      add_mines(n,size,mines) #do nothing if mine already placed
    else
      add_mines(n-1,size,Minesweeper.update_pos(mines,linha,coluna,true)) #add more mines until n=0
    end
  end
 end

 Engine.main()
