class Avatar
  getter image

  def initialize(image : String)
    @image = Path[image]
  end

  def thumbnail_path : Path
    if image.extension == ".svg"
      Path["images/u"].join(image)
    else
      Path["images/u/thumb"].join(image.basename(image.extension) + ".jpg") #/{{ creator.avatar | replace: "png", "jpg" }}"
    end
  end
end
