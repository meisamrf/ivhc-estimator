/*
IVHC Noise Estimation Python Wrapper
Meisam Rakhshanfar 2018
*/

#include <Python.h>

static PyObject *GenError;

int ivhcImgNoiseEstimation(float *img, int img_row, int img_col, float &sigma_p, float &sigma_o, 
	float *nlf_out, int &nlf_o_size);

PyObject* py_ivhc(PyObject *self, PyObject *args)
{
	PyObject *arg1, *arg2;
	Py_buffer b_imgin, b_nlfout;

	if (!PyArg_ParseTuple(args, "OO", &arg1, &arg2))
		return NULL;

	if (PyObject_GetBuffer(arg1, &b_imgin, PyBUF_FULL) < 0)
		return NULL;

	if (PyObject_GetBuffer(arg2, &b_nlfout, PyBUF_FULL) < 0)
		return NULL;

	if (b_imgin.itemsize != 4 || b_nlfout.itemsize != 4) {
		PyErr_SetString(GenError, "data type error (float32 required)");
		return NULL;
	}
	if (b_imgin.ndim != 2 || b_nlfout.ndim != 1) {
		PyErr_SetString(GenError, "dimension type error (2d input and 3d output required)");
		return NULL;
	}

	int img_row = (int)b_imgin.shape[0];
	int img_col = (int)b_imgin.shape[1];

	int nlf_size = (int)b_nlfout.shape[0];

	if (nlf_size != 256*3) {
		PyErr_SetString(GenError, "Output NLF size error.\n");
		return NULL;
	}

	if ((b_imgin.strides[0] != b_imgin.shape[1] * b_imgin.itemsize) && 
		(b_imgin.strides[1] != b_imgin.shape[0] * b_imgin.itemsize)) {
		PyErr_SetString(GenError, "Stride error.\n");
		return NULL;
	}

	float sigma_p, sigma_o;
	int nlf_o_size = 0;
	int results = ivhcImgNoiseEstimation((float *)b_imgin.buf, img_row, img_col, sigma_p, sigma_o, 
		(float *)b_nlfout.buf, nlf_o_size);

	if (results == 0) {
		PyErr_SetString(GenError, "Noise estimation error.\n");
		return NULL;
	}

	PyObject* resList = PyList_New(3);
	PyList_SetItem(resList, 0, PyFloat_FromDouble(sigma_p));
	PyList_SetItem(resList, 1, PyFloat_FromDouble(sigma_o));
	PyList_SetItem(resList, 2, PyLong_FromLong(nlf_o_size*3));
	PyBuffer_Release(&b_imgin);
	PyBuffer_Release(&b_nlfout);

	return resList;
}


PyMethodDef ivhcMethods[] = {
	{ "run", (PyCFunction)py_ivhc, METH_VARARGS, "IVHC Image Noise Estimation (image_in, nlf_out)" },
	{ NULL, NULL, 0, NULL }
};


static struct PyModuleDef ivhcmodule = {
	PyModuleDef_HEAD_INIT,
	"ivhc",
	"ivhc Module C++",
	-1,
	ivhcMethods
};

PyMODINIT_FUNC
PyInit_ivhc(void)
{
	PyObject *m = PyModule_Create(&ivhcmodule);

	if (m == NULL)
		return NULL;

	GenError = PyErr_NewException("ivhc.error", NULL, NULL);
	Py_INCREF(GenError);
	PyModule_AddObject(m, "error", GenError);

	return m;

}
