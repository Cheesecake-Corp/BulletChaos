using Godot;
using System;

public partial class StartGameButton : Button
{
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		var button = new Button();
		button.Text = "Start Game";
		button.Pressed += ButtonPressed;
		AddChild(button);
		
	}
	
	private void ButtonPressed()
	{
	GD.Print("Hello world!");
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}
	
	
}
