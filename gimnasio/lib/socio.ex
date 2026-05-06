defmodule Socio do
  @enforce_keys [:cedula, :nombre, :edad]
  defstruct [:cedula, :nombre, :edad, clases: []]

  def nuevo(cedula, nombre, edad) when is_integer(edad) and edad > 0 do
    cedula = String.trim(cedula)
    nombre = String.trim(nombre)

    cond do
      cedula == "" -> {:error, :cedula_invalida}
      nombre == "" -> {:error, :nombre_invalido}
      true -> {:ok, %__MODULE__{cedula: cedula, nombre: nombre, edad: edad, clases: []}}
    end
  end

  def nuevo(_cedula, _nombre, _edad), do: {:error, :edad_invalida}

  def inscribir_clase(%__MODULE__{clases: clases} = socio, clase) do
    clase = String.trim(clase)

    cond do
      clase == "" ->
        {:error, :clase_invalida}

      tiene_clase?(socio, clase) ->
        {:error, :clase_duplicada}

      true ->
        {:ok, %{socio | clases: clases ++ [clase]}}
    end
  end

  def desinscribir_clase(%__MODULE__{} = socio, clase) do
    clase = String.trim(clase)

    cond do
      clase == "" ->
        {:error, :clase_invalida}

      not tiene_clase?(socio, clase) ->
        {:error, :clase_no_encontrada}

      true ->
        {:ok, %{socio | clases: List.delete(socio.clases, clase)}}
    end
  end

  def tiene_clase?(%__MODULE__{clases: clases}, clase) do
    Enum.member?(clases, clase)
  end
end
