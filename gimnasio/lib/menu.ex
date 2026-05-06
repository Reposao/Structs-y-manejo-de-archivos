defmodule Menu do
  def main do
    Util.imprimir("================================")
    Util.imprimir("Sistema de socios del gimnasio")
    Util.imprimir("================================")

    case GestionArchivos.cargar_socios() do
      {:ok, socios} -> menu(socios)
      {:error, motivo} ->
        Util.imprimir("No se pudieron cargar los datos: #{inspect(motivo)}")
        menu(%{})
    end
  end

  defp menu(socios) do
    mostrar_opciones()

    opcion = Util.leer("Seleccione una opción: ", :integer)

    case opcion do
      1 -> crear_socio(socios) |> menu()
      2 -> eliminar_socio(socios) |> menu()
      3 -> inscribir_clase(socios) |> menu()
      4 -> desinscribir_clase(socios) |> menu()
      5 -> buscar_socio(socios) |> menu()
      6 -> listar_socios(socios) |> menu()
      7 -> listar_socios_clase(socios) |> menu()
      8 -> listar_clases_socio(socios) |> menu()
      0 -> salir()
      _ ->
        Util.imprimir("Opción no válida")
        menu(socios)
    end
  end

  defp mostrar_opciones do
    Util.imprimir("\n--------- MENÚ ---------")
    Util.imprimir("1. Crear socio")
    Util.imprimir("2. Eliminar socio")
    Util.imprimir("3. Inscribir a un socio en una clase")
    Util.imprimir("4. Desinscribir a un socio de una clase")
    Util.imprimir("5. Buscar un socio por cédula")
    Util.imprimir("6. Listar todos los socios")
    Util.imprimir("7. Listar socios de una clase")
    Util.imprimir("8. Listar clases de un socio")
    Util.imprimir("0. Salir")
    Util.imprimir("------------------------")
  end

  defp crear_socio(socios) do
    cedula = Util.leer("Ingrese la cédula: ", :string)
    nombre = Util.leer("Ingrese el nombre: ", :string)
    edad = Util.leer("Ingrese la edad: ", :integer)

    case Gimnasio.crear_socio(socios, cedula, nombre, edad) do
      {:ok, socios_actualizados} -> guardar(socios_actualizados, "Socio creado correctamente")
      {:error, motivo} -> error(socios, motivo)
    end
  end

  defp eliminar_socio(socios) do
    cedula = Util.leer("Ingrese la cédula del socio a eliminar: ", :string)

    case Gimnasio.eliminar_socio(socios, cedula) do
      {:ok, socios_actualizados} -> guardar(socios_actualizados, "Socio eliminado correctamente")
      {:error, motivo} -> error(socios, motivo)
    end
  end

  defp inscribir_clase(socios) do
    cedula = Util.leer("Ingrese la cédula: ", :string)
    clase = Util.leer("Ingrese la clase: ", :string)

    case Gimnasio.inscribir_clase(socios, cedula, clase) do
      {:ok, socios_actualizados} -> guardar(socios_actualizados, "Clase inscrita correctamente")
      {:error, motivo} -> error(socios, motivo)
    end
  end

  defp desinscribir_clase(socios) do
    cedula = Util.leer("Ingrese la cédula: ", :string)
    clase = Util.leer("Ingrese la clase a quitar: ", :string)

    case Gimnasio.desinscribir_clase(socios, cedula, clase) do
      {:ok, socios_actualizados} -> guardar(socios_actualizados, "Clase desinscrita correctamente")
      {:error, motivo} -> error(socios, motivo)
    end
  end

  defp buscar_socio(socios) do
    cedula = Util.leer("Ingrese la cédula: ", :string)

    case Gimnasio.buscar_socio(socios, cedula) do
      {:ok, socio} -> imprimir_socio(socio)
      {:error, motivo} -> Util.imprimir("Error: #{mensaje_error(motivo)}")
    end

    socios
  end

  defp listar_socios(socios) do
    case Gimnasio.listar_socios(socios) do
      {:ok, []} -> Util.imprimir("No hay socios registrados")
      {:ok, lista} -> Enum.each(lista, fn socio -> imprimir_socio(socio) end)
      {:error, motivo} -> Util.imprimir("Error: #{mensaje_error(motivo)}")
    end

    socios
  end

  defp listar_socios_clase(socios) do
    clase = Util.leer("Ingrese la clase a consultar: ", :string)

    case Gimnasio.listar_socios_clase(socios, clase) do
      {:ok, []} -> Util.imprimir("No hay socios en esa clase")
      {:ok, lista} -> Enum.each(lista, fn socio -> imprimir_socio(socio) end)
      {:error, motivo} -> Util.imprimir("Error: #{mensaje_error(motivo)}")
    end

    socios
  end

  defp listar_clases_socio(socios) do
    cedula = Util.leer("Ingrese la cédula: ", :string)

    case Gimnasio.listar_clases_socio(socios, cedula) do
      {:ok, []} -> Util.imprimir("El socio no tiene clases inscritas")
      {:ok, clases} -> Enum.each(clases, fn clase -> Util.imprimir(clase) end)
      {:error, motivo} -> Util.imprimir("Error: #{mensaje_error(motivo)}")
    end

    socios
  end

  defp guardar(socios, mensaje) do
    case GestionArchivos.guardar_socios(socios) do
      {:ok, _} ->
        Util.imprimir(mensaje)
        socios

      {:error, motivo} ->
        Util.imprimir("Se hizo la operación, pero no se pudo guardar: #{inspect(motivo)}")
        socios
    end
  end

  defp error(socios, motivo) do
    Util.imprimir("Error: #{mensaje_error(motivo)}")
    socios
  end

  defp imprimir_socio(%Socio{} = socio) do
    clases = case socio.clases do
      [] -> "Sin clases"
      _ -> Enum.join(socio.clases, ", ")
    end

    Util.imprimir("Cédula: #{socio.cedula} | Nombre: #{socio.nombre} | Edad: #{socio.edad} | Clases: #{clases}")
  end

  defp mensaje_error(:cedula_duplicada), do: "ya existe un socio con esa cédula"
  defp mensaje_error(:cedula_invalida), do: "la cédula es inválida"
  defp mensaje_error(:nombre_invalido), do: "el nombre es inválido"
  defp mensaje_error(:edad_invalida), do: "la edad debe ser positiva"
  defp mensaje_error(:socio_no_encontrado), do: "el socio no fue encontrado"
  defp mensaje_error(:clase_invalida), do: "la clase es inválida"
  defp mensaje_error(:clase_duplicada), do: "el socio ya está inscrito en esa clase"
  defp mensaje_error(:clase_no_encontrada), do: "el socio no está inscrito en esa clase"
  defp mensaje_error(motivo), do: inspect(motivo)

  defp salir do
    Util.imprimir("Saliendo del sistema...")
    System.halt(0)
  end
end
