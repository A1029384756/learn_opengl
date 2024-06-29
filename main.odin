package main

import "core:fmt"
import gl "vendor:OpenGL"
import "vendor:glfw"

framebuffer_size_callback :: proc "c" (window: glfw.WindowHandle, width, height: i32) {
	gl.Viewport(0, 0, width, height)
}

process_input :: proc(window: glfw.WindowHandle) {
	if glfw.GetKey(window, glfw.KEY_ESCAPE) == glfw.PRESS {
		glfw.SetWindowShouldClose(window, true)
	}
}

main :: proc() {
	glfw.Init()
	window := glfw.CreateWindow(800, 600, "LearnOpenGL", nil, nil)
	defer glfw.Terminate()
	defer glfw.DestroyWindow(window)

	if window == nil {
		fmt.println("Failed to create GLFW window")
		return
	}

	glfw.MakeContextCurrent(window)
	gl.load_up_to(4, 5, glfw.gl_set_proc_address)
	gl.Viewport(0, 0, 800, 600)
	glfw.SetFramebufferSizeCallback(window, framebuffer_size_callback)

	vertex_shader := gl.CreateShader(gl.VERTEX_SHADER)
	vertex_shader_source := #load("shaders/vert.glsl", cstring)
	gl.ShaderSource(vertex_shader, 1, &vertex_shader_source, nil)
	gl.CompileShader(vertex_shader)

	success: i32
	gl.GetShaderiv(vertex_shader, gl.COMPILE_STATUS, &success)
	if !bool(success) {
		fmt.println("ERROR - shader vertex compilation failed")
	}

	fragment_shader := gl.CreateShader(gl.FRAGMENT_SHADER)
	fragment_shader_source := #load("shaders/frag.glsl", cstring)
	gl.ShaderSource(fragment_shader, 1, &fragment_shader_source, nil)
	gl.CompileShader(fragment_shader)

	gl.GetShaderiv(fragment_shader, gl.COMPILE_STATUS, &success)
	if !bool(success) {
		fmt.println("ERROR - shader fragment compilation failed")
	}

	shader_program := gl.CreateProgram()
	gl.AttachShader(shader_program, vertex_shader)
	gl.AttachShader(shader_program, fragment_shader)
	gl.LinkProgram(shader_program)

	gl.GetProgramiv(shader_program, gl.LINK_STATUS, &success)
	if !bool(success) {
		fmt.println("ERROR - shader shader linking failed")
	}

	gl.DeleteShader(vertex_shader)
	gl.DeleteShader(fragment_shader)

	vertices := []f32{-0.5, -0.5, 0, 0.5, -0.5, 0, 0, 0.5, 0}

	vbo, vao: u32
	gl.GenVertexArrays(1, &vao)
	gl.GenBuffers(1, &vbo)
	gl.BindVertexArray(vao)

	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	gl.BufferData(gl.ARRAY_BUFFER, len(vertices), &vertices, gl.STATIC_DRAW)

	gl.VertexAttribPointer(0, 3, gl.FLOAT, false, 3 * size_of(f32), 0)
	gl.EnableVertexAttribArray(0)

	for !glfw.WindowShouldClose(window) {
		process_input(window)
		gl.ClearColor(0.5, 0, 1, 1)
		gl.Clear(gl.COLOR_BUFFER_BIT)

		gl.UseProgram(shader_program)
		gl.BindVertexArray(vao)
		gl.DrawArrays(gl.TRIANGLES, 0, 3)

		glfw.SwapBuffers(window)
		glfw.PollEvents()
	}
}
