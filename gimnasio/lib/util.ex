defmodule Util do
  def leer(mensaje, :string) do
    IO.gets(mensaje)
    |> String.trim()
  end

  def leer(mensaje, :integer) do
    leer_con_parser(mensaje, &Integer.parse/1)
  end

  defp leer_con_parser(mensaje, parser) do
    valor = IO.gets(mensaje)
    |> String.trim()
    |> parser.()

    case valor do
      {numero, ""} -> numero
      _ ->
        IO.puts("Valor inválido. Intente de nuevo.")
        leer_con_parser(mensaje, parser)
    end
  end

  def imprimir(mensaje) do
    IO.puts(mensaje)
  end
end
