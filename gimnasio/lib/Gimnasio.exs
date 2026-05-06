defmodule Gimnasio do
  def crear_socio(socios, cedula, nombre, edad) do
    if Map.has_key?(socios, cedula) do
      {:error, :cedula_duplicada}
    else
      case Socio.nuevo(cedula, nombre, edad) do
        {:ok, socio} -> {:ok, Map.put(socios, cedula, socio)}
        {:error, motivo} -> {:error, motivo}
      end
    end
  end

  def eliminar_socio(socios, cedula) do
    if Map.has_key?(socios, cedula) do
      {:ok, Map.delete(socios, cedula)}
    else
      {:error, :socio_no_encontrado}
    end
  end

  def buscar_socio(socios, cedula) do
    case Map.get(socios, cedula) do
      nil -> {:error, :socio_no_encontrado}
      socio -> {:ok, socio}
    end
  end

  def inscribir_clase(socios, cedula, clase) do
    case buscar_socio(socios, cedula) do
      {:ok, socio} ->
        case Socio.inscribir_clase(socio, clase) do
          {:ok, socio_actualizado} -> {:ok, Map.put(socios, cedula, socio_actualizado)}
          {:error, motivo} -> {:error, motivo}
        end

      {:error, motivo} ->
        {:error, motivo}
    end
  end

  def desinscribir_clase(socios, cedula, clase) do
    case buscar_socio(socios, cedula) do
      {:ok, socio} ->
        case Socio.desinscribir_clase(socio, clase) do
          {:ok, socio_actualizado} -> {:ok, Map.put(socios, cedula, socio_actualizado)}
          {:error, motivo} -> {:error, motivo}
        end

      {:error, motivo} ->
        {:error, motivo}
    end
  end

  def listar_socios(socios) do
    lista = Map.values(socios)
    |> Enum.sort_by(fn socio -> socio.cedula end)

    {:ok, lista}
  end

  def listar_socios_clase(socios, clase) do
    lista = Map.values(socios)
    |> Enum.filter(fn socio -> Socio.tiene_clase?(socio, clase) end)
    |> Enum.sort_by(fn socio -> socio.nombre end)

    {:ok, lista}
  end

  def listar_clases_socio(socios, cedula) do
    case buscar_socio(socios, cedula) do
      {:ok, socio} -> {:ok, socio.clases}
      {:error, motivo} -> {:error, motivo}
    end
  end
end
