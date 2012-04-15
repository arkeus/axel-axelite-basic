package {
	import org.axgl.Ax;
	import org.axgl.render.AxColor;
	
	[SWF(width = "480", height = "360", backgroundColor = "#000000")]

	public class AxeliteBasic extends Ax {
		public function AxeliteBasic() {
			super(GameState);
		}
		
		override public function create():void {
			Ax.background = AxColor.fromHex(0x95c7e8);
		}
	}
}
