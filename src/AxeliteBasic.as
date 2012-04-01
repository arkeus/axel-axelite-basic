package {
	import org.axgl.Ax;
	import org.axgl.render.AxColor;
	
	[SWF(width = "480", height = "360", backgroundColor = "#000000")]

	public class AxeliteBasic extends Ax {
		public function AxeliteBasic() {
			super(480, 360, new GameState);
			Ax.background = new AxColor(149/255, 199/255, 232/255);
		}
	}
}
