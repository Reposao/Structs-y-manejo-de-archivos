defmodule GestionArchivos do
  @ruta Path.expand("../socios.csv", __DIR__)
  @encabezado "cedula,nombre,edad,clases\n"

  def cargar_socios do
    case asegurar_archivo() do
      :ok -> leer_archivo()
      {:error, motivo} -> {:error, motivo}
    end
  end

  def guardar_socios(socios) do
    case asegurar_archivo() do
      :ok -> escribir_archivo(socios)
      {:error, motivo} -> {:error, motivo}
    end
  end

  defp asegurar_archivo do
    if File.exists?(@ruta) do
      :ok
    else
      case File.write(@ruta, @encabezado) do
        :ok -> :ok
        {:error, motivo} -> {:error, motivo}
      end
    end
  end

  defp leer_archivo do
    case File.read(@ruta) do
      {:ok, contenido} -> {:ok, parsear_contenido(contenido)}
      {:error, motivo} -> {:error, motivo}
    end
  end

  defp escribir_archivo(socios) do
    contenido = convertir_csv(socios)

    case File.write(@ruta, contenido) do
      :ok -> {:ok, :guardado}
      {:error, motivo} -> {:error, motivo}
    end
  end

  defp parsear_contenido(contenido) do
    contenido
    |> String.split("\n", trim: true)
    |> Enum.drop(1)
    |> Enum.reduce(%{}, fn linea, acc ->
      case parsear_linea(linea) do
        {:ok, socio} -> Map.put(acc, socio.cedula, socio)
        {:error, _} -> acc
      end
    end)
  end

  defp parsear_linea(linea) do
    partes = String.split(linea, ",", parts: 4)

    case partes do
      [cedula, nombre, edad, clases] ->
        case Integer.parse(String.trim(edad)) do
          {edad_numero, ""} ->
            case Socio.nuevo(String.trim(cedula), String.trim(nombre), edad_numero) do
              {:ok, socio} ->
                {:ok, %{socio | clases: convertir_clases(clases)}}

              {:error, motivo} ->
                {:error, motivo}
            end

          _ ->
            {:error, :edad_invalida}
        end

      _ ->
        {:error, :linea_invalida}
    end
  end

  defp convertir_clases(clases) do
    clases
    |> String.trim()
    |> case do
      "" -> []
      texto ->
        texto
        |> String.split(";", trim: true)
        |> Enum.map(fn clase -> String.trim(clase) end)
    end
  end

  defp convertir_csv(socios) do
    lineas = Map.values(socios)
    |> Enum.sort_by(fn socio -> socio.cedula end)
    |> Enum.map(fn socio -> serializar_socio(socio) end)
    |> Enum.join("\n")

    case lineas do
      "" -> @encabezado
      _ -> @encabezado <> lineas <> "\n"
    end
  end

  defp serializar_socio(%Socio{} = socio) do
    clases = Enum.join(socio.clases, ";")
    "#{socio.cedula},#{socio.nombre},#{socio.edad},#{clases}"
  end
end
