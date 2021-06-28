#!/bin/bash  

BUILD_IMAGE_W_TAG=$1

# configure tags ###############################################################################
build_image_w_tag=${BUILD_IMAGE_W_TAG:=ericsgagnon/buildpack-deps-cuda:cuda11.3-ubuntu20.04}
additional_image_tag=${ADDITIONAL_IMAGE_TAG:=ericsgagnon/buildpack-deps-cuda:cuda11-ubuntu20.04}

# configure and build ##########################################################################
root_dir=$(git rev-parse --show-toplevel)
echo "Root Directory: ${root_dir}"
echo "Build Tag: ${build_image_w_tag}"
build_context="${root_dir}/${STAGE}"
echo "Build Context: ${build_context}"

echo ${build_context}

docker build --pull --no-cache=true -t ${build_image_w_tag}  -f ${build_context}/Dockerfile . 
build_exit_code=$?

if [[ $build_exit_code -ne 0 ]] ; then
   echo "build failed"
   exit 1
fi

# push build ###################################################################################
echo "docker push ${build_image_w_tag}"
docker push ${build_image_w_tag}
push_exit_code=$?
if [[ ${push_exit_code} -ne 0 ]] ; then
  echo "push failed: ${build_image_w_tag}"
  exit 1
fi

# re-tag and push ##############################################################################
echo "docker tag  ${build_image_w_tag} ${additional_image_tag}"
docker tag  ${build_image_w_tag} ${additional_image_tag}
echo "docker push ${additional_image_tag}"
docker push ${additional_image_tag}
push_exit_code=$?
if [[ ${push_exit_code} -ne 0 ]] ; then
  echo "push failed: ${additional_image_tag}"
  exit 1
fi

# how to test ##################################################################################
echo "test the image by:"
echo "docker run -d -i -t --name buildpack-deps --gpus all ${build_image_w_tag} && docker exec -i -t buildpack-deps /bin/bash"
echo "or:"
echo "docker run --rm -i -t --name buildpack-deps --gpus all ${build_image_w_tag} nvidia-smi"
echo "# cleanup"
echo "docker rm -fv buildpack-deps"

