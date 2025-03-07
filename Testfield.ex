defmodule Testfield do
  def get_arr([h|_t], 0), do: h
  def get_arr([_h|t], n), do: get_arr(t, n-1)

  def get_pos(tab,l,c), do: get_arr(get_arr(tab, l), c)

  def is_mine(minas,l,c) do
    cond do
      get_pos(minas, l, c) == true -> true
      true -> false
    end
  end

end
