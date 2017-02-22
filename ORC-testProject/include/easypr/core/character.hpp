//////////////////////////////////////////////////////////////////////////
// Name:	    CHARACTER Header
// Version:		1.0
// Date:	    2016-06-14
// Author:	    liuruoze
// Copyright:   liuruoze
// Desciption:
// An abstract class for car character in plate.
//////////////////////////////////////////////////////////////////////////
#ifndef EASYPR_CORE_CHARACTER_H_
#define EASYPR_CORE_CHARACTER_H_

#include "opencv2/opencv.hpp"

using namespace cv;

/*! \namespace easypr
Namespace where all the C++ EasyPR functionality resides
*/
namespace easypr {

  class CCharacter {
  public:
    CCharacter()
    {
      m_characterMat = Mat();
      m_characterPos = cv::Rect();
      m_characterStr = "";
      m_score = 0;
      m_isChinese = false;
      m_ostuLevel = 125;
        m_center = cv::Point(0, 0);
    }

    CCharacter(const CCharacter& other)
    {
      m_characterMat = other.m_characterMat;
      m_characterPos = other.m_characterPos;
      m_characterStr = other.m_characterStr;
      m_score = other.m_score;
      m_isChinese = other.m_isChinese;
      m_ostuLevel = other.m_ostuLevel;
      m_center = other.m_center;
    }

    inline void setCharacterMat(Mat param) { m_characterMat = param; }
    inline Mat getCharacterMat() const { return m_characterMat; }

      inline void setCharacterPos(cv::Rect param) { m_characterPos = param; }
    inline cv::Rect getCharacterPos() const { return m_characterPos; }

    inline void setCharacterStr(String param) { m_characterStr = param; }
    inline String getCharacterStr() const { return m_characterStr; }

    inline void setCharacterScore(double param) { m_score = param; }
    inline double getCharacterScore() const { return m_score; }

    inline void setIsChinese(bool param) { m_isChinese = param; }
    inline bool getIsChinese() const { return m_isChinese; }

    inline void setOstuLevel(double param) { m_ostuLevel = param; }
    inline double getOstuLevel() const { return m_ostuLevel; }

      inline void setCenterPoint(cv::Point param) { m_center = param; }
      inline cv::Point getCenterPoint() const { return m_center; }

    inline bool getIsStrong() const { return m_score >= 0.9; }
    inline bool getIsWeak() const { return m_score < 0.9 && m_score >= 0.5; }
    inline bool getIsLittle() const { return m_score < 0.5; }

    bool operator < (const CCharacter& other) const
    {
      return (m_score > other.m_score);
    }

    bool operator < (const CCharacter& other)
    {
      return (m_score > other.m_score);
    }

  private:
    //! character mat
    Mat m_characterMat;

    //! character rect
      cv::Rect m_characterPos;

    //! character str
    String m_characterStr;

    //! character likely
    double m_score;

    //! weather is chinese
    bool m_isChinese;

    //! ostu level
    double m_ostuLevel;

    //! center point
      cv::Point m_center;

    ////!  m_score >= 0.9
    //bool isStrong;

    ////!  m_score < 0.9 && m_score >= 0.5
    //bool isWeak;

    ////!  m_score < 0.5 
    //bool isLittle;
  };

} /*! \namespace easypr*/

#endif  // EASYPR_CORE_PLATE_H_