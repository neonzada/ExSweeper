defmodule Minesweeper do
  @moduledoc """
  A module that implements functions for the game Minesweeper.
  """

  # get_arr/2 (get array):  recebe uma lista (vetor) e uma posicao (n) e devolve o elemento
  # na posição n do vetor. O vetor começa na posição 0 (zero). Não é necessário tratar erros.
  def get_arr([h|_t], 0), do: h
  def get_arr([_h|t], n), do: get_arr(t, n-1)

  # update_arr/3 (update array): recebe uma lista(vetor), uma posição (n) e um novo valor (v) e devolve um
  # novo vetor com o valor v na posição n. O vetor começa na posição 0 (zero)
  def update_arr([_h|t],0,v), do: [v|t]
  def update_arr([h|t],n,v), do: [h|update_arr(t, n-1, v)]

  # get_pos/3 (get position): recebe um tabuleiro (matriz), uma linha (l) e uma coluna (c) (não precisa validar).
  # Devolve o elemento na posicao tabuleiro[l,c]. Usar get_arr/2 na implementação
  def get_pos(tab,l,c), do: get_arr(get_arr(tab, l), c)

  # update_pos/4 (update position): recebe um tabuleiro, uma linha, uma coluna e um novo valor. Devolve
  # o tabuleiro modificado com o novo valor na posiçao linha x coluna. Usar update_arr/3 e get_arr/2 na implementação
  def update_pos(tab,l,c,v), do: update_arr(get_arr(tab, l), c, v)

  #-- is_mine/3: recebe um tabuleiro com o mapeamento das minas, uma linha, uma coluna. Devolve true caso a posição contenha
  # uma mina e false caso contrário.
  def is_mine(minas,l,c) do
    cond do
      get_pos(minas, l, c) == true -> true
      true -> false
    end
  end


  # is_valid_pos/3 recebe o tamanho do tabuleiro (ex, em um tabuleiro 9x9, o tamanho é 9),
  # uma linha e uma coluna, e diz se essa posição é válida no tabuleiro.
  def is_valid_pos(size,l,c), do: l < size && c < size && l >= 0 && c >= 0

  # valid_moves/3: Dado o tamanho do tabuleiro e uma posição atual (linha e coluna), retorna uma lista
  # com todas as posições adjacentes à posição atual
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

  # conta_minas_adj/3: recebe um tabuleiro com o mapeamento das minas e uma posicao (linha e coluna), e conta quantas minas
  # existem nas posições adjacentes
  def conta_minas_adj(tab,l,c) do
    valid_moves(Enum.count(tab),l,c)
    |> Enum.filter(fn {l, c} -> is_mine(tab,l,c) end)
    |> Enum.count()
  end

  # abre_jogada/4: é a função principal do jogo!!
  # recebe uma posição a ser aberta (linha e coluna), o mapa de minas e o tabuleiro do jogo. Devolve como
  # resposta o tabuleiro do jogo modificado com essa jogada.
  # Essa função é recursiva, pois no caso da entrada ser uma posição sem minas adjacentes, o algoritmo deve
  # seguir abrindo todas as posições adjacentes até que se encontre posições adjacentes à minas.
  # Vamos analisar os casos:
  # - Se a posição a ser aberta é uma mina, o tabuleiro não é modificado e encerra
  # - Se a posição a ser aberta já foi aberta, o tabuleiro não é modificado e encerra
  # - Se a posição a ser aberta é adjacente a uma ou mais minas, devolver o tabuleiro modificado com o número de
  # minas adjacentes na posição aberta
  # - Se a posição a ser aberta não possui minas adjacentes, abrimos ela com zero (0) e recursivamente abrimos
  # as outras posições adjacentes a ela
  def abre_jogada(l, c, minas, tab) do
    adjMines = conta_minas_adj(minas,l,c)
    cond do
      is_mine(minas,l,c) -> end_game(minas,tab)               #mine, end game
      get_pos(tab,l,c) == 0 -> tab                            #already open, return tab
      adjMines > 0 -> update_pos(tab,l,c,adjMines)            #adjMines, return tab with num
      false ->
        #open with 0 and recursively open other adjacent positions
        {l,c} = valid_moves(Enum.count(tab),l,c) #TODO: pattern match for every tuple returned by valid_moves
        abre_jogada(l,c,minas,update_pos(tab,l,c,0))
    end

    # case is_mine(minas, l, c) do
    #   # If mine, end game
    #   true -> end_game(minas, tab)

    #   # If not, check if its already open
    #   false ->
    #     if get_pos(tab, l, c) == 0 do tab end
    #     minas_adj = conta_minas_adj(minas, l, c)
    #     if minas_adj > 0 do
    #       update_pos(tab, l, c, minas_adj)
    #     else
    #       update_pos(tab, l, c, 0)
    #       valid_moves(Enum.count(tab), l, c)
    #     end
    # end
  end

# abre_posicao/4, que recebe um tabueiro de jogos, o mapa de minas, uma linha e uma coluna
# Essa função verifica:
# - Se a posição {l,c} já está aberta (contém um número), então essa posição não deve ser modificada
# - Se a posição {l,c} contém uma mina no mapa de minas, então marcar  com "*" no tabuleiro
# - Se a posição {l,c} está fechada (contém "-"), escrever o número de minas adjascentes a esssa posição no tabuleiro (usar conta_minas)
  def abre_posicao(tab,minas,l,c) do
    cond do
      is_mine(minas, l, c) -> update_pos(tab, l, c, "*")
      get_pos(tab, l, c) == "-" -> update_pos(tab, l, c, conta_minas_adj(tab, l, c))
      false -> tab #TODO: idk if return tab here is correct
    end
  end



# abre_tabuleiro/2: recebe o mapa de Minas e o tabuleiro do jogo, e abre todo o tabuleiro do jogo, mostrando
# onde estão as minas e os números nas posições adjecentes às minas.Essa função é usada para mostrar
# todo o tabuleiro no caso de vitória ou derrota. Para implementar esta função, usar a função abre_posicao/4

  #TODO: make ts work
  def abre_tabuleiro(minas,tab) do
    #abre_posicao(tab, minas, l, c)
  end

# board_to_string/1: -- Recebe o tabuleiro do jogo e devolve uma string que é a representação visual desse tabuleiro.
# Essa função é aplicada no tabuleiro antes de fazer o print dele na tela. Usar a sua imaginação para fazer um
# tabuleiro legal. Olhar os exemplos no .pdf com a especificação do trabalho. Não esquecer de usar \n para quebra de linhas.
# Você pode quebrar essa função em mais de uma: print_header, print_linhas, etc...

  #TODO: test ts
  def board_to_string(tab) do
    header = print_header(length(hd(tab)))
    rows = print_rows(tab)
    header <> rows
  end

  defp print_header(size) do
    letters = Enum.map(?A..(?A + size - 1), &<<&1>>)
    "   " <> Enum.join(letters, "   ") <> " \n"
  end

  defp print_rows(tab) do
    tab
    |> Enum.with_index(1)
    |> Enum.map(&print_row/1)
    |> Enum.join("   " <> String.duplicate("-", length(hd(tab)) * 4 - 1) <> " \n")
  end

  defp print_row({row, index}) do
    row_string = row |> Enum.join(" | ")
    "#{index}  " <> row_string <> " \n"
  end

# gera_lista/2: recebe um inteiro n, um valor v, e gera uma lista contendo n vezes o valor v
  def gera_lista(0,_v), do: []
  def gera_lista(n,v), do: [v|gera_lista(n-1, v)]

# -- gera_tabuleiro/1: recebe o tamanho do tabuleiro de jogo e gera um tabuleiro  novo, todo fechado (todas as posições
# contém "-"). Usar gera_lista
  def gera_tabuleiro(n), do: gera_lista(n, gera_lista(n, "-"))

# -- gera_mapa_de_minas/1: recebe o tamanho do tabuleiro e gera um mapa de minas zero, onde todas as posições contém false
  def gera_mapa_de_minas(n), do: gera_lista(n, gera_lista(n, false))


# conta_fechadas/1: recebe um tabueleiro de jogo e conta quantas posições fechadas existem no tabuleiro (posições com "-")
  def conta_fechadas(tab) do
    tab
    |> Enum.flat_map(& &1)
    |> Enum.count(&(&1 == "-"))
  end

# -- conta_minas/1: Recebe o tabuleiro de Minas (MBoard) e conta quantas minas existem no jogo
  def conta_minas(minas) do
    minas
    |> Enum.flat_map(& &1)
    |> Enum.count(&(&1 == true))
  end

# end_game?/2: recebe o tabuleiro de minas, o tauleiro do jogo, e diz se o jogo acabou.
# O jogo acabou quando o número de casas fechadas é igual ao numero de minas
  def end_game(minas,tab), do: conta_fechadas(tab) == conta_minas(minas)

end


#engine code
defmodule Engine do
  @moduledoc """
  Engine that handles minesweeper logic.
  """
  def main() do
   v = IO.gets("Digite o tamanho do tabuleiro: \n")
   {size,_} = Integer.parse(v)
   minas = gen_mines_board(size) #TODO: something wrong here
   #IO.puts("oi")
   IO.inspect minas
   tabuleiro = Minesweeper.gera_tabuleiro(size)
   game_loop(minas,tabuleiro)
  end
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
  def gen_mines_board(size) do
    add_mines(ceil(size*size*0.15), size, Minesweeper.gera_mapa_de_minas(size))
  end
  def add_mines(0,_size,mines), do: mines
  def add_mines(n,size,mines) do
    linha = :rand.uniform(size-1)
    coluna = :rand.uniform(size-1)
    if Minesweeper.is_mine(mines,linha,coluna) do
      add_mines(n,size,mines)
    else
      add_mines(n-1,size,Minesweeper.update_pos(mines,linha,coluna,true))
    end
  end
 end

 Engine.main()
