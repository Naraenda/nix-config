self: super: {
  blender = super.blender.override { 
    cudaSupport = true; 
  };
}