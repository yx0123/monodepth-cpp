# Build Tensorflow C++ library from source to local folder (adapted from original README)
Tested with Tensorflow 2.3.1, CUDA 10.1, CuDNN 7.6.0, Protobuf 3.9.0, bazel 3.7.1. I recommend using the same build configuration to ensure compatability. 

## Instructions:

### 1. Dependencies

```
sudo apt-get install autoconf automake libtool curl make g++ unzip  #Protobuf Dependencies
sudo apt-get install python-numpy swig python-dev python-wheel      #TensorFlow Dependencies
```

#### [Protobuf](https://github.com/protocolbuffers/protobuf/blob/master/src/README.md)
```
git clone https://github.com/protocolbuffers/protobuf.git
cd protobuf
git checkout v3.9.0
git submodule update --init --recursive
./autogen.sh
./configure
make
make check
sudo make install
sudo ldconfig # refresh shared library cache.
```
If "make check" fails, you can still install, but it is likely that some features of this library will not work correctly on your system. Proceed at your own risk.

#### [Bazel](https://docs.bazel.build/versions/3.7.0/install-ubuntu.html) 
Add Bazel distribution URI as a package source
```
sudo apt install curl gnupg
curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > bazel.gpg
sudo mv bazel.gpg /etc/apt/trusted.gpg.d/
echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list
```
Install 
```
sudo apt update && sudo apt install bazel
```
The bazel package will always install the latest stable version of Bazel. Install bazel-3.1.0 in addition to the latest one like this:
```
sudo apt install bazel-3.1.0
```

#### CUDA
Install development and runtime libraries
```
sudo apt-get install --no-install-recommends cuda-10-1 
```
#### CuDNN
Refer to [this guide](https://docs.nvidia.com/deeplearning/cudnn/install-guide/index.html) for installation instructions. In step 2.3, if you follow the instructions in 2.3.1. Tar File Installation, you can ignore step 2.4. Instead, run ``` cat /usr/local/cuda/include/cudnn.h | grep CUDNN_MAJOR -A 2```. You should see the following output:
```
#define CUDNN_MAJOR 7
#define CUDNN_MINOR 6
#define CUDNN_PATCHLEVEL 0
--
#define CUDNN_VERSION (CUDNN_MAJOR * 1000 + CUDNN_MINOR * 100 + CUDNN_PATCHLEVEL)

#include "driver_types.h"
```
### 2. Clone Tensorflow source

```
git clone https://github.com/tensorflow/tensorflow                 
cd tensorflow
git checkout v2.3.1
bash tensorflow/lite/tools/make/download_dependencies.sh
```

### 3. Append the following to tensorflow/tensorflow/BUILD file:

```
cc_binary(
    name = "libtensorflow_all.so",
    linkshared = 1,
    linkopts = ["-Wl,--version-script=tensorflow/tf_version_script.lds"], # Remove this line if you are using MacOS
    deps = [
        "//tensorflow/core:framework_internal",
        "//tensorflow/core:tensorflow",
        "//tensorflow/cc:cc_ops",
        "//tensorflow/cc:client_session",
        "//tensorflow/cc:scope",
        "//tensorflow/c:c_api",
    ],
)
```

### 4. Build the shared library (locally)

```
./configure (I use default settings)
bazel build --config=opt --config=cuda --config=monolithic tensorflow:libtensorflow_all.so (append '-j 4' or lower number to limit computational resources)
```
### 5. Organize Tensorflow library in local folder

```
cd ~/tensorflow
mkdir -p local/lib
cp bazel-bin/tensorflow/libtensorflow_all.so local/lib 
mkdir -p local/include/google/tensorflow
cp -r tensorflow local/include/google/tensorflow
cp bazel-bin/tensorflow/core/framework/*.h local/include/google/tensorflow/tensorflow/core/framework
cp bazel-tensorflow/tensorflow/core/kernels/*.h local/include/google/tensorflow/tensorflow/core/kernels
cp bazel-bin/tensorflow/core/lib/core/*.h local/include/google/tensorflow/tensorflow/core/lib/core
cp bazel-bin/tensorflow/core/protobuf/*.h local/include/google/tensorflow/tensorflow/core/protobuf
cp bazel-bin/tensorflow/core/util/*.h local/include/google/tensorflow/tensorflow/core/util
cp bazel-bin/tensorflow/cc/ops/*.h local/include/google/tensorflow/tensorflow/cc/ops
cp -r third_party local/include/google/tensorflow/
```


# Original README below:
# Build Tensorflow C++ library from source to local folder
I am using Tensorflow 1.6, CUDA 8.0, and cuDNN 6.0

Special instructions or notes are given in parentheses, do not copy them

If you already have the library, feel free to use your own library

## Instructions:

1. Install dependencies

```
sudo apt-get install autoconf automake libtool curl make g++ unzip  (Protobuf Dependencies)
sudo apt-get install python-numpy swig python-dev python-wheel      (TensorFlow Dependencies)
```

2. Clone Tensorflow source

```
git clone https://github.com/tensorflow/tensorflow                 
cd tensorflow
git checkout (OPTIONAL other version e.g. v1.6.0)
bash tensorflow/contrib/makefile/download_dependencies.sh (then install dependencies separately)
```

3. Append the following to tensorflow/BUILD file:

```
cc_binary(
    name = "libtensorflow_all.so",
    linkshared = 1,
    linkopts = ["-Wl,--version-script=tensorflow/tf_version_script.lds"], # Remove this line if you are using MacOS
    deps = [
        "//tensorflow/core:framework_internal",
        "//tensorflow/core:tensorflow",
        "//tensorflow/cc:cc_ops",
        "//tensorflow/cc:client_session",
        "//tensorflow/cc:scope",
        "//tensorflow/c:c_api",
    ],
)
```

4. Build the shared library (locally)

```
./configure (I use default settings)
bazel build --config=opt --config=cuda --config=monolithic tensorflow:libtensorflow_all.so (append '-j 4' or lower number to limit computational resources)
```

5. Organize Tensorflow library in local folder

```
cd ~/tensorflow
mkdir -p local/lib
cp bazel-bin/tensorflow/libtensorflow_all.so local/lib 
mkdir -p local/include/google/tensorflow
cp -r tensorflow local/include/google/tensorflow
cp bazel-genfiles/tensorflow/core/framework/*.h local/include/google/tensorflow/tensorflow/core/framework
cp bazel-tensorflow/tensorflow/core/kernels/*.h local/include/google/tensorflow/tensorflow/core/kernels
cp bazel-genfiles/tensorflow/core/lib/core/*.h local/include/google/tensorflow/tensorflow/core/lib/core
cp bazel-genfiles/tensorflow/core/protobuf/*.h local/include/google/tensorflow/tensorflow/core/protobuf
cp bazel-genfiles/tensorflow/core/util/*.h local/include/google/tensorflow/tensorflow/core/util
cp bazel-genfiles/tensorflow/cc/ops/*.h local/include/google/tensorflow/tensorflow/cc/ops
cp -r third_party local/include/google/tensorflow/
```

## Note:
* In case of errors in Bazel build, downgrade Bazel to lower version

```
curl -LO "https://github.com/bazelbuild/bazel/releases/download/0.11.1/bazel_0.11.1-linux-x86_64.deb" 
$ sudo dpkg -i bazel_*.deb
```

* Before raising any issues, be sure to checkout the **Issues** in the referenced Github repos. You should be able to identify similar issue faced by others.

## Reference:
[Official Tensorflow guide](https://www.tensorflow.org/install/install_sources)

[Tensorflow-cmake](https://github.com/cjweeks/tensorflow-cmake)


