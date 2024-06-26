  package com.candlefinance.fasterimage

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.ColorMatrix
import android.graphics.ColorMatrixColorFilter
import android.graphics.Outline
import android.graphics.Rect
import android.graphics.RectF
import android.graphics.Path
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.os.Build
import android.util.Base64
import android.view.View
import android.view.ViewOutlineProvider
import android.widget.ImageView.ScaleType
import androidx.appcompat.widget.AppCompatImageView
import coil.annotation.ExperimentalCoilApi
import coil.imageLoader
import coil.request.CachePolicy
import coil.request.ImageRequest
import coil.size.Scale
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.uimanager.events.RCTEventEmitter

  data class BorderRadii(
    val uniform: Double,
    val topLeft: Double,
    val topRight: Double,
    val bottomLeft: Double,
    val bottomRight: Double,
  ) {
    fun sum(): Double {
      return uniform + topLeft + topRight + bottomLeft + bottomRight;
    }
  }

  @Suppress("unused")
  class FasterImageModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {
    override fun getName(): String = "FasterImageModule"

    @OptIn(ExperimentalCoilApi::class)
    @ReactMethod
    fun clearCache(promise: Promise) {
      val imageLoader = reactApplicationContext.imageLoader
      imageLoader.memoryCache?.clear()
      imageLoader.diskCache?.clear()
      promise.resolve(true)
    }
  }

  class FasterImageViewManager : SimpleViewManager<AppCompatImageView>() {
    override fun getName() = "FasterImageView"

    override fun createViewInstance(reactContext: ThemedReactContext): AppCompatImageView {
      return AppCompatImageView(reactContext)
    }

    override fun getExportedCustomBubblingEventTypeConstants(): Map<String, Any> {
      return mapOf(
        "onError" to mapOf(
          "phasedRegistrationNames" to mapOf(
            "bubbled" to "onError"
          )
        ),
        "onSuccess" to mapOf(
          "phasedRegistrationNames" to mapOf(
            "bubbled" to "onSuccess"
          )
        )
      )
    }

     @ReactProp(name = "source")
      fun setImageSource(view: AppCompatImageView, options: ReadableMap) {
        val url = options.getString("url")
        val base64Placeholder = options.getString("base64Placeholder")
        val thumbHash = options.getString("thumbhash")
        val resizeMode = options.getString("resizeMode")
        val transitionDuration = if (options.hasKey("transitionDuration")) options.getInt("transitionDuration") else 100
        val cachePolicy = options.getString("cachePolicy")
        val failureImage = options.getString("failureImage")
        val grayscale = if (options.hasKey("grayscale")) options.getDouble("grayscale") else 0.0
        val allowHardware = if (options.hasKey("allowHardware")) options.getBoolean("allowHardware") else true
       val headers = options.getMap("headers")

        val borderRadii = BorderRadii(
          uniform = if (options.hasKey("borderRadius")) options.getDouble("borderRadius") else 0.0,
          topLeft = if (options.hasKey("borderTopLeftRadius")) options.getDouble("borderTopLeftRadius") else 0.0,
          topRight = if (options.hasKey("borderTopRightRadius")) options.getDouble("borderTopRightRadius") else 0.0,
          bottomLeft = if (options.hasKey("borderBottomLeftRadius")) options.getDouble("borderBottomLeftRadius") else 0.0,
          bottomRight = if (options.hasKey("borderBottomRightRadius")) options.getDouble("borderBottomRightRadius") else 0.0,
        )

        if (borderRadii.sum() != 0.0) {
          setViewBorderRadius(view, borderRadii)
        }

      if (RESIZE_MODE.containsKey(resizeMode)) {
        view.scaleType = RESIZE_MODE[resizeMode]
      } else {
        view.scaleType = ScaleType.FIT_CENTER
      }

       val drawablePlaceholder: Drawable? = base64Placeholder?.let { getDrawableFromBase64(it, view) }
       val failureDrawable: Drawable? = failureImage?.let { getDrawableFromBase64(it, view) }
       val thumbHashDrawable = thumbHash?.let { makeThumbHash(view, it) }

       var requestBuilder = ImageRequest.Builder(view.context)
       // Handle base64 image sources
       url?.let {
         if (it.startsWith("data:image")) {
           requestBuilder = requestBuilder.data(
             getDrawableFromBase64(it.substringAfter("base64,"), view)
           )
         } else {
           requestBuilder = requestBuilder.data(it)
           headers?.let {
             for (entry in it.entryIterator) {
               requestBuilder.setHeader(entry.key, entry.value as String)
             }
           }
         }
       }

       val imageLoader = view.context.imageLoader;
       val request = requestBuilder
          .target(
            onStart = { placeholder ->
              view.setImageDrawable(placeholder)
            },
            onSuccess = { result ->
              val event = Arguments.createMap()
              event.putString("source", url)
              event.putString("height", result.intrinsicHeight.toString())
              event.putString("width", result.intrinsicWidth.toString())
              val reactContext = view.context as ReactContext
              reactContext
                .getJSModule(RCTEventEmitter::class.java)
                .receiveEvent(view.id, "onSuccess", event)

              if (grayscale == 0.0) {
                view.setImageDrawable(result)
              } else {
                val grayscaleDrawable = result.mutate()
                val colorMatrix = ColorMatrix().apply {
                    setSaturation((1.0 - grayscale).toFloat())
                }
                val colorFilter = ColorMatrixColorFilter(colorMatrix)
                grayscaleDrawable.colorFilter = colorFilter
                view.setImageDrawable(grayscaleDrawable)
              }
            },
            onError = { error ->
                val event = Arguments.createMap()
                event.putString("error", "failed to load image")
                val reactContext = view.context as ReactContext
                reactContext
                  .getJSModule(RCTEventEmitter::class.java)
                  .receiveEvent(view.id, "onError", event)
                view.setImageDrawable(error ?: failureDrawable)
            }
          )
          .crossfade(transitionDuration.toInt() ?: 100)
          .placeholder(drawablePlaceholder ?: thumbHashDrawable)
          .error(failureDrawable ?: drawablePlaceholder)
          .fallback(failureDrawable ?: drawablePlaceholder)
          .memoryCachePolicy(if (cachePolicy == "memory") CachePolicy.ENABLED else CachePolicy.DISABLED)
          .diskCachePolicy(if (cachePolicy == "discWithCacheControl" || cachePolicy == "discNoCacheControl") CachePolicy.ENABLED else CachePolicy.DISABLED)
          .allowHardware(allowHardware)
          .build()

          imageLoader.enqueue(request)
     }

      private fun setViewBorderRadius(view: AppCompatImageView, borderRadii: BorderRadii) {
        view.clipToOutline = true
        view.outlineProvider = object : ViewOutlineProvider() {
          override fun getOutline(view: View, outline: Outline) {
            val width = view.width
            val height = view.height
            val nonUniformRadiiSum = borderRadii.sum() - borderRadii.uniform

            if (nonUniformRadiiSum == 0.0 || nonUniformRadiiSum == borderRadii.uniform) {
              outline.setRoundRect(0, 0, width, height, borderRadii.uniform.toFloat())
              return
            }

            val radii = floatArrayOf(
              borderRadii.topLeft.toFloat(), borderRadii.topLeft.toFloat(),
              borderRadii.topRight.toFloat(), borderRadii.topRight.toFloat(),
              borderRadii.bottomRight.toFloat(), borderRadii.bottomRight.toFloat(),
              borderRadii.bottomLeft.toFloat(), borderRadii.bottomLeft.toFloat(),
            )

            val rect = Rect(0, 0, width, height)

            val path = Path().apply {
              addRoundRect(
                RectF(rect),
                radii,
                Path.Direction.CW
              )
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
              outline.setPath(path)
            } else {
              outline.setRoundRect(rect, borderRadii.sum().toFloat())
            }
          }
        }
      }

      private fun getDrawableFromBase64(base64: String, view: AppCompatImageView): Drawable {
        val decodedString: ByteArray = Base64.decode(base64, Base64.DEFAULT)
        val decodedByte = BitmapFactory.decodeByteArray(decodedString, 0, decodedString.size)
        return BitmapDrawable(view.context.resources, decodedByte)
      }

      private fun makeThumbHash(view: AppCompatImageView, hash: String): Drawable {
        val thumbHash = ThumbHash.thumbHashToRGBA(Base64.decode(hash, Base64.DEFAULT))
        val bitmap = Bitmap.createBitmap(thumbHash.width, thumbHash.height, Bitmap.Config.ARGB_8888)
        bitmap.setPixels(toIntArray(thumbHash.rgba), 0, thumbHash.width, 0, 0, thumbHash.width, thumbHash.height)
        return BitmapDrawable(view.context.resources, bitmap)
      }

      private fun toIntArray(byteArray: ByteArray): IntArray {
        val intArray = IntArray(byteArray.size)
        for (i in byteArray.indices) {
          intArray[i] = byteArray[i].toInt() and 0xFF
        }
        return intArray
      }

    companion object {
      private val RESIZE_MODE = mapOf(
        "contain" to ScaleType.FIT_CENTER,
        "cover" to ScaleType.CENTER_CROP,
        "fill" to ScaleType.FIT_XY,
        "center" to ScaleType.CENTER_INSIDE,
        "top" to ScaleType.FIT_START,
        "bottom" to ScaleType.FIT_END,
      )

      private val SCALE_TYPE = mapOf(
        "fit" to Scale.FIT,
        "fill" to Scale.FILL
      )
    }
  }

  object ThumbHash {
    /**
     * Encodes an RGBA image to a ThumbHash. RGB should not be premultiplied by A.
     *
     * @param w    The width of the input image. Must be ≤100px.
     * @param h    The height of the input image. Must be ≤100px.
     * @param rgba The pixels in the input image, row-by-row. Must have w*h*4 elements.
     * @return The ThumbHash as a byte array.
     */
    fun rgbaToThumbHash(w: Int, h: Int, rgba: ByteArray): ByteArray {
      // Encoding an image larger than 100x100 is slow with no benefit
      require(!(w > 100 || h > 100)) { w.toString() + "x" + h + " doesn't fit in 100x100" }

      // Determine the average color
      var avg_r = 0f
      var avg_g = 0f
      var avg_b = 0f
      var avg_a = 0f
      run {
        var i = 0
        var j = 0
        while (i < w * h) {
          val alpha = (rgba[j + 3].toInt() and 255) / 255.0f
          avg_r += alpha / 255.0f * (rgba[j].toInt() and 255)
          avg_g += alpha / 255.0f * (rgba[j + 1].toInt() and 255)
          avg_b += alpha / 255.0f * (rgba[j + 2].toInt() and 255)
          avg_a += alpha
          i++
          j += 4
        }
      }
      if (avg_a > 0) {
        avg_r /= avg_a
        avg_g /= avg_a
        avg_b /= avg_a
      }
      val hasAlpha = avg_a < w * h
      val l_limit = if (hasAlpha) 5 else 7 // Use fewer luminance bits if there's alpha
      val lx = Math.max(1, Math.round((l_limit * w).toFloat() / Math.max(w, h).toFloat()))
      val ly = Math.max(1, Math.round((l_limit * h).toFloat() / Math.max(w, h).toFloat()))
      val l = FloatArray(w * h) // luminance
      val p = FloatArray(w * h) // yellow - blue
      val q = FloatArray(w * h) // red - green
      val a = FloatArray(w * h) // alpha

      // Convert the image from RGBA to LPQA (composite atop the average color)
      var i = 0
      var j = 0
      while (i < w * h) {
        val alpha = (rgba[j + 3].toInt() and 255) / 255.0f
        val r = avg_r * (1.0f - alpha) + alpha / 255.0f * (rgba[j].toInt() and 255)
        val g = avg_g * (1.0f - alpha) + alpha / 255.0f * (rgba[j + 1].toInt() and 255)
        val b = avg_b * (1.0f - alpha) + alpha / 255.0f * (rgba[j + 2].toInt() and 255)
        l[i] = (r + g + b) / 3.0f
        p[i] = (r + g) / 2.0f - b
        q[i] = r - g
        a[i] = alpha
        i++
        j += 4
      }

      // Encode using the DCT into DC (constant) and normalized AC (varying) terms
      val l_channel = Channel(Math.max(3, lx), Math.max(3, ly)).encode(w, h, l)
      val p_channel = Channel(3, 3).encode(w, h, p)
      val q_channel = Channel(3, 3).encode(w, h, q)
      val a_channel = if (hasAlpha) Channel(5, 5).encode(w, h, a) else null

      // Write the constants
      val isLandscape = w > h
      val header24 = (Math.round(63.0f * l_channel.dc)
        or (Math.round(31.5f + 31.5f * p_channel.dc) shl 6)
        or (Math.round(31.5f + 31.5f * q_channel.dc) shl 12)
        or (Math.round(31.0f * l_channel.scale) shl 18)
        or if (hasAlpha) 1 shl 23 else 0)
      val header16 = ((if (isLandscape) ly else lx)
        or (Math.round(63.0f * p_channel.scale) shl 3)
        or (Math.round(63.0f * q_channel.scale) shl 9)
        or if (isLandscape) 1 shl 15 else 0)
      val ac_start = if (hasAlpha) 6 else 5
      val ac_count = (l_channel.ac.size + p_channel.ac.size + q_channel.ac.size
        + if (hasAlpha) a_channel!!.ac.size else 0)
      val hash = ByteArray(ac_start + (ac_count + 1) / 2)
      hash[0] = header24.toByte()
      hash[1] = (header24 shr 8).toByte()
      hash[2] = (header24 shr 16).toByte()
      hash[3] = header16.toByte()
      hash[4] = (header16 shr 8).toByte()
      if (hasAlpha) hash[5] = (Math.round(15.0f * a_channel!!.dc)
        or (Math.round(15.0f * a_channel.scale) shl 4)).toByte()

      // Write the varying factors
      var ac_index = 0
      ac_index = l_channel.writeTo(hash, ac_start, ac_index)
      ac_index = p_channel.writeTo(hash, ac_start, ac_index)
      ac_index = q_channel.writeTo(hash, ac_start, ac_index)
      if (hasAlpha) a_channel!!.writeTo(hash, ac_start, ac_index)
      return hash
    }

    /**
     * Decodes a ThumbHash to an RGBA image. RGB is not be premultiplied by A.
     *
     * @param hash The bytes of the ThumbHash.
     * @return The width, height, and pixels of the rendered placeholder image.
     */
    fun thumbHashToRGBA(hash: ByteArray): Image {
      // Read the constants
      val header24 = hash[0].toInt() and 255 or (hash[1].toInt() and 255 shl 8) or (hash[2].toInt() and 255 shl 16)
      val header16 = hash[3].toInt() and 255 or (hash[4].toInt() and 255 shl 8)
      val l_dc = (header24 and 63).toFloat() / 63.0f
      val p_dc = (header24 shr 6 and 63).toFloat() / 31.5f - 1.0f
      val q_dc = (header24 shr 12 and 63).toFloat() / 31.5f - 1.0f
      val l_scale = (header24 shr 18 and 31).toFloat() / 31.0f
      val hasAlpha = header24 shr 23 != 0
      val p_scale = (header16 shr 3 and 63).toFloat() / 63.0f
      val q_scale = (header16 shr 9 and 63).toFloat() / 63.0f
      val isLandscape = header16 shr 15 != 0
      val lx = Math.max(3, if (isLandscape) if (hasAlpha) 5 else 7 else header16 and 7)
      val ly = Math.max(3, if (isLandscape) header16 and 7 else if (hasAlpha) 5 else 7)
      val a_dc = if (hasAlpha) (hash[5].toInt() and 15).toFloat() / 15.0f else 1.0f
      val a_scale = (hash[5].toInt() shr 4 and 15).toFloat() / 15.0f

      // Read the varying factors (boost saturation by 1.25x to compensate for quantization)
      val ac_start = if (hasAlpha) 6 else 5
      var ac_index = 0
      val l_channel = Channel(lx, ly)
      val p_channel = Channel(3, 3)
      val q_channel = Channel(3, 3)
      var a_channel: Channel? = null
      ac_index = l_channel.decode(hash, ac_start, ac_index, l_scale)
      ac_index = p_channel.decode(hash, ac_start, ac_index, p_scale * 1.25f)
      ac_index = q_channel.decode(hash, ac_start, ac_index, q_scale * 1.25f)
      if (hasAlpha) {
        a_channel = Channel(5, 5)
        a_channel.decode(hash, ac_start, ac_index, a_scale)
      }
      val l_ac = l_channel.ac
      val p_ac = p_channel.ac
      val q_ac = q_channel.ac
      val a_ac = if (hasAlpha) a_channel!!.ac else null

      // Decode using the DCT into RGB
      val ratio = thumbHashToApproximateAspectRatio(hash)
      val w = Math.round(if (ratio > 1.0f) 32.0f else 32.0f * ratio)
      val h = Math.round(if (ratio > 1.0f) 32.0f / ratio else 32.0f)
      val rgba = ByteArray(w * h * 4)
      val cx_stop = Math.max(lx, if (hasAlpha) 5 else 3)
      val cy_stop = Math.max(ly, if (hasAlpha) 5 else 3)
      val fx = FloatArray(cx_stop)
      val fy = FloatArray(cy_stop)
      var y = 0
      var i = 0
      while (y < h) {
        var x = 0
        while (x < w) {
          var l = l_dc
          var p = p_dc
          var q = q_dc
          var a = a_dc

          // Precompute the coefficients
          for (cx in 0 until cx_stop) fx[cx] = Math.cos(Math.PI / w * (x + 0.5f) * cx).toFloat()
          for (cy in 0 until cy_stop) fy[cy] = Math.cos(Math.PI / h * (y + 0.5f) * cy).toFloat()

          // Decode L
          run {
            var cy = 0
            var j = 0
            while (cy < ly) {
              val fy2 = fy[cy] * 2.0f
              var cx = if (cy > 0) 0 else 1
              while (cx * ly < lx * (ly - cy)) {
                l += l_ac[j] * fx[cx] * fy2
                cx++
                j++
              }
              cy++
            }
          }

          // Decode P and Q
          var cy = 0
          var j = 0
          while (cy < 3) {
            val fy2 = fy[cy] * 2.0f
            var cx = if (cy > 0) 0 else 1
            while (cx < 3 - cy) {
              val f = fx[cx] * fy2
              p += p_ac[j] * f
              q += q_ac[j] * f
              cx++
              j++
            }
            cy++
          }

          // Decode A
          if (hasAlpha) {
            var cy = 0
            var j = 0
            while (cy < 5) {
              val fy2 = fy[cy] * 2.0f
              var cx = if (cy > 0) 0 else 1
              while (cx < 5 - cy) {
                a += a_ac!![j] * fx[cx] * fy2
                cx++
                j++
              }
              cy++
            }
          }

          // Convert to RGB
          val b = l - 2.0f / 3.0f * p
          val r = (3.0f * l - b + q) / 2.0f
          val g = r - q
          rgba[i] = Math.max(0, Math.round(255.0f * Math.min(1f, r))).toByte()
          rgba[i + 1] = Math.max(0, Math.round(255.0f * Math.min(1f, g))).toByte()
          rgba[i + 2] = Math.max(0, Math.round(255.0f * Math.min(1f, b))).toByte()
          rgba[i + 3] = Math.max(0, Math.round(255.0f * Math.min(1f, a))).toByte()
          x++
          i += 4
        }
        y++
      }
      return Image(w, h, rgba)
    }

    /**
     * Extracts the average color from a ThumbHash. RGB is not be premultiplied by A.
     *
     * @param hash The bytes of the ThumbHash.
     * @return The RGBA values for the average color. Each value ranges from 0 to 1.
     */
    fun thumbHashToAverageRGBA(hash: ByteArray): RGBA {
      val header = hash[0].toInt() and 255 or (hash[1].toInt() and 255 shl 8) or (hash[2].toInt() and 255 shl 16)
      val l = (header and 63).toFloat() / 63.0f
      val p = (header shr 6 and 63).toFloat() / 31.5f - 1.0f
      val q = (header shr 12 and 63).toFloat() / 31.5f - 1.0f
      val hasAlpha = header shr 23 != 0
      val a = if (hasAlpha) (hash[5].toInt() and 15).toFloat() / 15.0f else 1.0f
      val b = l - 2.0f / 3.0f * p
      val r = (3.0f * l - b + q) / 2.0f
      val g = r - q
      return RGBA(
        Math.max(0f, Math.min(1f, r)),
        Math.max(0f, Math.min(1f, g)),
        Math.max(0f, Math.min(1f, b)),
        a)
    }

    /**
     * Extracts the approximate aspect ratio of the original image.
     *
     * @param hash The bytes of the ThumbHash.
     * @return The approximate aspect ratio (i.e. width / height).
     */
    fun thumbHashToApproximateAspectRatio(hash: ByteArray): Float {
      val header = hash[3]
      val hasAlpha = hash[2].toInt() and 0x80 != 0
      val isLandscape = hash[4].toInt() and 0x80 != 0
      val lx = if (isLandscape) if (hasAlpha) 5 else 7 else header.toInt() and 7
      val ly = if (isLandscape) header.toInt() and 7 else if (hasAlpha) 5 else 7
      return lx.toFloat() / ly.toFloat()
    }

    class Image(var width: Int, var height: Int, var rgba: ByteArray)
    class RGBA(var r: Float, var g: Float, var b: Float, var a: Float)
    private class Channel internal constructor(var nx: Int, var ny: Int) {
      var dc = 0f
      var ac: FloatArray
      var scale = 0f

      init {
        var n = 0
        for (cy in 0 until ny) {
          var cx = if (cy > 0) 0 else 1
          while (cx * ny < nx * (ny - cy)) {
            n++
            cx++
          }
        }
        ac = FloatArray(n)
      }

      fun encode(w: Int, h: Int, channel: FloatArray): Channel {
        var n = 0
        val fx = FloatArray(w)
        for (cy in 0 until ny) {
          var cx = 0
          while (cx * ny < nx * (ny - cy)) {
            var f = 0f
            for (x in 0 until w) fx[x] = Math.cos(Math.PI / w * cx * (x + 0.5f)).toFloat()
            for (y in 0 until h) {
              val fy = Math.cos(Math.PI / h * cy * (y + 0.5f)).toFloat()
              for (x in 0 until w) f += channel[x + y * w] * fx[x] * fy
            }
            f /= (w * h).toFloat()
            if (cx > 0 || cy > 0) {
              ac[n++] = f
              scale = Math.max(scale, Math.abs(f))
            } else {
              dc = f
            }
            cx++
          }
        }
        if (scale > 0) for (i in ac.indices) ac[i] = 0.5f + 0.5f / scale * ac[i]
        return this
      }

      fun decode(hash: ByteArray, start: Int, index: Int, scale: Float): Int {
        var index = index
        for (i in ac.indices) {
          val data = hash[start + (index shr 1)].toInt() shr (index and 1 shl 2)
          ac[i] = ((data and 15).toFloat() / 7.5f - 1.0f) * scale
          index++
        }
        return index
      }

      fun writeTo(hash: ByteArray, start: Int, index: Int): Int {
        var index = index
        for (v in ac) {
          hash[start + (index shr 1)] = (hash[start + (index shr 1)].toInt() or (Math.round(15.0f * v) shl (index and 1 shl 2))).toByte()
          index++
        }
        return index
      }
    }
  }
