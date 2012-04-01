package org.axgl.text {
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.geom.Vector3D;
	
	import org.axgl.Ax;
	import org.axgl.AxModel;
	import org.axgl.render.AxColor;
	import org.axgl.resource.AxResource;

	/**
	 * Creates text for display on the screen using the given AxFont.
	 */
	public class AxText extends AxModel {
		/**
		 * The actual string to draw to the screen.
		 */
		private var _text:String;
		/**
		 * The font to use when drawing the text.
		 */
		public var font:AxFont;
		/**
		 * The alignment to draw the string with, either "left", "right", or "center".
		 * @default left
		 */
		public var align:String;

		/**
		 * Creates a new text at the given position, using the given font. If width is 0, it will not wrap at all. If
		 * width is greater than zero, will wrap the text in as many lines as needed to keep it within that width.
		 * The alignment will only have an effect if you have a fixed width.
		 * 
		 * @param x The x coordinate to draw the text at.
		 * @param y The y coordinate to draw the text at.
		 * @param font The AxFont to use when drawing the text.
		 * @param text The actual string to display.
		 * @param width The max-width of the text, required for alignment. Will wrap to stay within this width.
		 * @param align The alignment of the text, either "left", "right", or "center".
		 *
		 */
		public function AxText(x:Number, y:Number, font:AxFont, text:String, width:uint = 0, align:String = "left") {
			super(x, y, VERTEX_SHADER, FRAGMENT_SHADER, 8);

			this._text = text;
			this.font = font ? font : AxResource.FONT;
			this.width = width;
			this.align = align;

			build();
		}

		/**
		 * Splits the passed text into lines using the given font and the given width.
		 * 
		 * @param text The text to split into lines.
		 * @param font The font to use when splitting the text.
		 * @param width The maximum width to wrap the lines at.
		 *
		 * @return A vector of text lines.
		 */
		public static function split(text:String, font:AxFont, width:uint):Vector.<AxTextLine> {
			var lines:Vector.<AxTextLine> = new Vector.<AxTextLine>;
			var spaceWidth:int = font.characterWidth(" ");

			var lineArray:Array = text.split("\n");
			var line:String = "";
			var lineWidth:int = 0;
			var inTag:Boolean = false;

			for each (var lineString:String in lineArray) {
				var wordArray:Array = lineString.split(" ");
				for each (var wordString:String in wordArray) {
					var wordWidth:int = 0;
					var characterArray:Array = wordString.split("");
					for (var i:uint = 0; i < characterArray.length; i++) {
						var character:String = characterArray[i];
						if (character == "@" && characterArray[i + 1] == "[") {
							inTag = true;
						} else if (character == "]" && inTag) {
							inTag = false;
							continue;
						}

						if (!inTag) {
							wordWidth += font.characterWidth(character) + font.spacing.x;
						}
					}

					wordWidth -= font.spacing.x;

					if (lineWidth + wordWidth > width) {
						lines.push(new AxTextLine(line, lineWidth));
						lineWidth = 0;
						line = "";
					}

					if (!inTag) {
						line += (line == "" ? "" : " ") + wordString;
						lineWidth += wordWidth + font.spacing.x * 2 + spaceWidth;
					}
				}

				lines.push(new AxTextLine(line, lineWidth));
				lineWidth = 0;
				line = "";
			}

			return lines;
		}

		/**
		 * Builds the mesh required to draw this object's text. Any time the text changes, this must be rebuilt and uploaded
		 * to the GPU.
		 */
		private function build():void {
			if (_text.length == 0) {
				return;
			}
			
			indexData = new Vector.<uint>;
			vertexData = new Vector.<Number>;

			var lines:Vector.<AxTextLine> = width == 0 ? Vector.<AxTextLine>([new AxTextLine(_text, 0)]) : split(_text, font, width);
			var y:uint = 0;
			var index:uint = 0;
			var color:AxColor = new AxColor;
			for each (var textLine:AxTextLine in lines) {
				var x:uint = 0;
				if (align == "right") {
					x = width - textLine.width;
				} else if (align == "center") {
					x = (width - textLine.width) / 2;
				}


				var characters:Array = textLine.text.split("");
				for (var i:uint = 0; i < characters.length; i++) {
					var character:String = characters[i];

					// Handle Colors
					if (character == "@" && characters[i + 1] == "[") {
						var closing:int = characters.indexOf("]", i + 1);
						var colorCode:String = textLine.text.substring(i + 2, closing);
						if (colorCode == "") {
							color.r = color.g = color.b = color.a = 1;
						} else {
							var colorPieces:Array = colorCode.split(",");
							color.r = parseInt(colorPieces[0]) / 255;
							color.g = parseInt(colorPieces[1]) / 255;
							color.b = parseInt(colorPieces[2]) / 255;
							if (colorPieces.length > 3) {
								color.a = parseInt(colorPieces[3]) / 255;
							} else {
								color.a = 1;
							}
						}
						i = closing;
						continue;
					}

					var c:AxCharacter = font.character(character);
					if (c == null) {
						continue;
					}
					
					//trace("building", c.width, c.height);
					
					indexData.push(index, index + 1, index + 2, index + 1, index + 2, index + 3);
					vertexData.push(
						//  x 			y				u						v
						x, 				y,				c.uv.x,					c.uv.y,					color.r, color.g, color.b, color.a,
						x + c.width,	y,				c.uv.x + c.uv.width,	c.uv.y,					color.r, color.g, color.b, color.a,
						x,				y + c.height,	c.uv.x,					c.uv.y + c.uv.height,	color.r, color.g, color.b, color.a,
						x + c.width,	y + c.height,	c.uv.x + c.uv.width,	c.uv.y + c.uv.height,	color.r, color.g, color.b, color.a
					);
					index += 4;
					x += c.width + font.spacing.x;
				}
				
				y += font.height + font.spacing.y;
			}

			var vertexLength:uint = vertexData.length / shader.rowSize;
			indexBuffer = Ax.context.createIndexBuffer(indexData.length);
			indexBuffer.uploadFromVector(indexData, 0, indexData.length);
			vertexBuffer = Ax.context.createVertexBuffer(vertexLength, shader.rowSize);
			vertexBuffer.uploadFromVector(vertexData, 0, vertexLength);
			triangles = indexData.length / 3;
		}

		/**
		 * Sets the text to the given string, returning if it hasn't changed, in order to prevent rebuilding
		 * the mesh when not needed.
		 * 
		 * @param str The string to set the text to.
		 */
		public function set text(str:String):void {
			if (_text == str) {
				return;
			}
			_text = str;
			build();
		}
		
		/**
		 * Returns the text of this object.
		 */
		public function get text():String {
			return _text;
		}

		override public function draw():void {
			if (_text.length == 0) {
				return;
			}
			
			matrix.identity();
			if (angle != 0) {
				matrix.appendRotation(angle, Vector3D.Z_AXIS, pivot);
			}
			matrix.appendScale(scale.x, scale.y, 1);
			matrix.appendTranslation(x - Ax.camera.x * scroll.x, y - Ax.camera.y * scroll.y, 0);
			matrix.append(zooms ? Ax.camera.projection : Ax.camera.baseProjection);

			Ax.context.setProgram(shader.program);
			Ax.context.setTextureAt(0, font.texture.texture);
			Ax.context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			Ax.context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, matrix, true);
			Ax.context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, colorTransform);
			Ax.context.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			Ax.context.setVertexBufferAt(1, vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2);
			Ax.context.setVertexBufferAt(2, vertexBuffer, 4, Context3DVertexBufferFormat.FLOAT_4);
			Ax.context.drawTriangles(indexBuffer, 0, triangles);
			Ax.context.setVertexBufferAt(0, null, 0, Context3DVertexBufferFormat.FLOAT_2);
			Ax.context.setVertexBufferAt(1, null, 2, Context3DVertexBufferFormat.FLOAT_2);
			Ax.context.setVertexBufferAt(2, null, 4, Context3DVertexBufferFormat.FLOAT_4);
			
			if (countTris) {
				Ax.debugger.tris += triangles;
			}
		}
		
		/**
		 * The vertex shader for this text.
		 */
		private static const VERTEX_SHADER:Array = [
			// va0 = [x, y, , ]
			// va1 = [u, v, , ]
			// vc0 = transform matrix
			"mov v1, va1",			// move uv to fragment shader
			"mov v2, va2",			// move rgba to fragment shader
			"m44 op, va0, vc0"		// multiply position by transform matrix 
		];
		
		/**
		 * The fragment shader for this text.
		 */
		private static const FRAGMENT_SHADER:Array = [
			// ft0 = texture sampled color
			// v1  = uv
			// fs0 = tilemap texture
			// fc0 = color
			"tex ft0, v1, fs0 <2d,nearest,mipnone>",	// sample texture
			"mul ft1, fc0, v2",						    // multiply global color by color of character
			"mul oc, ft1, ft0",							// multiply by color+alpha
		];
	}
}
